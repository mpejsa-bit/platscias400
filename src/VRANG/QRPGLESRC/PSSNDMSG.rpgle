       ctl-opt DFTACTGRP(*NO) actgrp(*NEW) option(*NODEBUGIO);
       ctl-opt BNDDIR('YAJL') BNDDIR('LIBHTTPPS/HTTPAPI');
       ctl-opt BNDDIR('PLATSCI/PSSRVPGMS');

        dcl-f pldrvhdrp usage(*input:*update:*output) keyed;
        dcl-f pltintp usage(*input) keyed;
        dcl-f plscope usage(*input) keyed;
        dcl-f units usage(*input) keyed;

      /include yajl_h
      /include platsci/platsci,psloggerp
      /include LIBHTTPPS/qrpglesrc,httpapi_h

       dcl-s driver1 char(10) inz(*blanks);
       dcl-s driver2 char(10) inz(*blanks);
       dcl-s offset char(2);
       dcl-s ArrDataOptions char(200) inz('');
       dcl-s ResponseMessage varchar(16000000);
       dcl-s rc int(10);
       dcl-s Server char(256);
       dcl-s myJson varchar(16000000);
       dcl-s JsonBuild char(5000);
       dcl-s UnitNumber Char(6);

       // Procedure used for Timezone converting
       Dcl-PR plttimz Extpgm('RTVTIMZ');
        offset char(2);
       End-PR;

         // DS to get the HTTP Request Response Success
         dcl-ds Success qualified;
          num_data int(10) inz(0);
           dcl-ds data dim(1);
             external_id char(36) inz('');
             subject char(200) inz('');
            num_recipients int(10) inz(0);
             dcl-ds recipients dim(2);
               external_id Char(30) inz('');
               name char(30) inz('');
             end-ds;
           end-ds;
         end-ds;

         // DS to get the HTTP Request Response Failure
         dcl-ds Failure qualified;
          status_code packed(3:0) inz(0);
          message varchar(1000);
         end-ds;

        Dcl-pr SendMessage extpgm('PSSNDMSG');
            *n char(10);                      // Driver ID
            *n char(5000);                    // Message
            *n char(50);                      // Deeplink
            *n char(50) options(*nopass);     // Subject
            *n char(10) options(*nopass);     // Priority
            *n char(200) options(*nopass);    // Error response
        End-PR;

        dcl-pi SendMessage;
         driverID char(10);
         FFmessage char(5000);
         deepLink char(50);
         conversationName char(50) options(*nopass);
         messagePriority char(10) options(*nopass);
         ErrorReturn char(200) options(*nopass);
        end-pi;

        dcl-ds OutgoingMessage qualified;
         dcl-ds CONVERSATION;
           SUBJECT varchar(50) inz('');
            EXTERNAL_ID varchar(36) inz('');
            READ_ONLY ind;
            IS_GROUP_CHAT ind;
          end-ds;
         MESSAGE varchar(5000) inz('');
         PRIORITY varchar(10) inz('');
         num_RECIPIENTS int(10) inz(0);
         RECIPIENTS varchar(6) inz('') dim(1);
         TIMESTAMP varchar(26) inz('');
        end-ds;

       dcl-ds UTCFormat;
         msgDate char(10);
         msgSep1 char(1) inz('T');
         msgTime char(8);
         msgSep2 char(1) inz('+');
         msgTimeOff char(5);
       end-ds;

       ArrDataOptions =
         'allowextra=yes doc=string case=convert allowmissing=yes +
          countprefix=num_';


        EXEC SQL
         Select undr1, undr2, ununit INTO :Driver1, :Driver2, :UnitNumber
         FROM Units Where undr1 = :DriverID
         Fetch first 1 rows only;
          If SQLCOD = 0;
            If driver1 <> *Blanks;
             DriverID = Driver1;
             exsr formatJson;
             exsr sendOutboundMessage;
            Endif;

            If Driver2 <> *Blanks;
             Clear DriverID;
             DriverID = Driver2;
             exsr formatJson;
             exsr sendOutboundMessage;
            Endif;
          Endif;

       *inlr = *on;

        //-----------------------------------------------
        //      formatJson
        //-----------------------------------------------
       begsr formatJson;

         yajl_genOpen(*OFF);  // use *ON for easier to read JSON
                              //    *OFF for more compact JSON
         yajl_beginObj();
          yajl_addChar('conversation');
           yajl_beginObj();

         chain (driverId) pldrvhdrp;
        if %found(pldrvhdrp);
          yajl_addChar('subject':%trim(plhdrsbj));
          yajl_addChar('external_id':%trim(plhdrxid));
        endif;

        yajl_addBool('read_only':'0');
        yajl_addBool('is_group_chat':'0');

         yajl_endObj();
         yajl_addChar('message':%trim(FFmessage));
         If MessagePriority <> *Blanks;
           yajl_addChar('priority':%trim(messagePriority));
         Endif;

         if DeepLink <> *blanks;
          yajl_addChar('deeplink_id':%trim(Deeplink));
          yajl_addChar('deeplink_type':'macro');
         endif;

          yajl_beginArray('recipients');
          yajl_addChar(%trim(driverID));

        //if driver2 <> *blank;
        //yajl_addChar(%trim(driver2));
        //endif;

          yajl_endArray();

         yajl_beginObj();
         msgDate = %char(%date():*ISO);
         msgTime = %char(%time():*HMS);
         plttimz(offset);
         msgTimeOff = offset + ':00';
         yajl_addChar('timestamp': UTCFormat);
          yajl_endObj();
          JsonBuild = yajl_copyBufStr();
          yajl_genClose();
        endsr;

       //----------------------------------------------------------
       // Send Outbound mesage
       //----------------------------------------------------------
       Begsr sendOutboundMessage;

        http_setCCSIDs( 1208: 0 );
        HTTP_debug(*on);
        HTTP_SetFileCCSID(1208);

        // Also need code here to set up 'additional headers'
          http_xproc( HTTP_POINT_ADDL_HEADER
                      : %paddr(add_headers) );
          monitor;
          open pltintp;
          read pltintp;
          on-error;
          read pltintp;
          close pltintp;
          endmon;

        Exsr CreateURLAndSendMessage;

       Endsr;
       //-----------------------------------------------------------
       // Create URL
       //-----------------------------------------------------------
       Begsr CreateURLAndSendMessage;

        Server = %trim(%trim(pltinturl) + %trim(pltitmsgep));
        myJson = JsonBuild;

         //Send web service request to platform science
         rc= http_req('POST':
                       %trim(Server)
                      : *OMIT
                      : ResponseMessage
                      : *OMIT
                      : myJson
                      : 'application/json');

         if rc <> 1;
          Exsr CaptureFailure;
         else;
          Exsr CaptureSuccess;
         endif;

        Endsr;
        //------------------------------------------------------------
        // Cature Failure Message
        //-----------------------------------------------------------
        Begsr CaptureFailure;
         monitor;
          data-into Failure %DATA( ResponseMessage
                : 'doc=string case=convert allowextra=yes')
                  %PARSER( 'YAJLINTO'
                     : '{ "document_name": "Failure" }');
          pLogEntry = 'Message Errored with ' +
                      %char(Failure.status_code) + ' - ' +
                      %trim(Failure.message);
          pLogType = '*INFO';
          pDriverID = Driver1;
          pDriver2Id = Driver2;
          pLoadID = *Blanks;
          pTtruckID = UnitNumber;
          psLogger(pLogType :pgmds.procpgm :pDriverID :pDriver2ID:
                   pTtruckID :pLoadID: pLogEntry :pJsonString);
        on-error;
        endmon;
       Endsr;
       //------------------------------------------------------------
       // Cature Success Message
       //------------------------------------------------------------
       Begsr CaptureSuccess;
        monitor;
        data-into success %DATA( ResponseMessage
               : 'doc=string case=convert countprefix=num_')
                  %PARSER( 'YAJLINTO'
                     : '{ "document_name": "success", +
                          "number_prefix": "YAJL_"}');

         //save external_Id and subject to driver table.
           If success.data(1).subject > *Blanks Or
              success.data(1).external_id > *Blanks;

            chain (driverId) pldrvhdrp;
            if %found(pldrvhdrp);
              plhdrsbj = %trim(success.data(1).subject);
              plhdrxid = %trim(success.data(1).external_id);
              update rpldrvhdr;
            else;
              plhdrdrv = driverId;
              plhdrsbj = %trim(success.data(1).subject);
              plhdrxid = %trim(success.data(1).external_id);
              write rpldrvhdr;
            endif;
          endif;
         on-error;
         endmon;
         ErrorReturn = *bLanks;
       Endsr;
       //---------------------------------------------------------------
     P add_headers     B
     D                 PI
     D   headers                  32767a   varying
     D CRLF            C                   x'0d25'
     D token           s           1224
     D scope           s             30

          // code to calculate 'token' should go here.
           scope = '"messaging"';
           chain(n) scope plscope;
           if %found(plscope) = *on;
           token = plttoken;
           endif;

            headers = 'api-version: 2.0' + CRLF
                    + 'Authorization: Bearer ' + token + CRLF;
        /end-free
     P                 E
