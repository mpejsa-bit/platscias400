       ctl-opt DFTACTGRP(*NO) actgrp(*NEW) option(*NODEBUGIO);
       ctl-opt BNDDIR('YAJL') BNDDIR('LIBHTTPPS/HTTPAPI');
       ctl-opt BNDDIR('PLATSCI/PSSRVPGMS');

        dcl-f pldrvhdrp usage(*input:*update:*output) keyed;
        dcl-f pltintp usage(*input) keyed;
        dcl-f plscope usage(*input) keyed;
        dcl-f PSOBFFMSL3 usage(*input) keyed;

      /include yajl_h
      /include platsci/platsci,psloggerp
      /include LIBHTTPPS/qrpglesrc,httpapi_h

       dcl-s driver1 char(10) inz(*blanks);
       dcl-s driver2 char(10) inz(*blanks);
       dcl-s DriverID char(10) inz(*blanks);
       dcl-s offset char(2);
       dcl-s ArrDataOptions char(200) inz('');
       dcl-s ResponseMessage varchar(16000000);
       dcl-s rc int(10);
       dcl-s Server char(256);
       dcl-s myJson varchar(16000000);
       dcl-s JsonBuild char(5000);
       dcl-s UnitNumber Char(6);

       dcl-s dlytime uns(10);
       dcl-s dataLen packed(5:0);
       dcl-ds inputDs LikeRec(PSOBFFMSGR: *Input);

       dcl-pr ReceiveDQData ExtPgm('QRCVDTAQ');
         *n char(10) Const;           //DQ Name
         *n char(10) Const;           //DQ Lib Name
         *n packed(5:0);              //Data Length
         *n likeDS(inputDS);          //Data
         *n packed(5:0) Const;        //Wait time
       end-pr;

       dcl-pr sleep int(10) extproc('sleep') ;
        *n uns(10) value;
       end-pr;

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

        monitor;
          open pltintp;
          read pltintp;
        on-error;
          read pltintp;
          close pltintp;
        endmon;

        Server = %trim(%trim(pltinturl) + %trim(pltitmsgep));

        dou *inlr = *on;

          Clear inputDS;
          Clear driver1;
          Clear driver2;

          dataLen = 0;

          ReceiveDQData('PSOBLODQ1':
                 'PLATSCI': dataLen: inputDS :0);

          If dataLen > 0; //Process it

            If inputDS.PSDRV1 <> *Blanks;
              Clear DriverId;
              DriverId = inputDS.PSDRV1;
              exsr formatJson;
              exsr sendOutboundMessage;
            Endif;

            If inputDS.PSDRV2 <> *Blanks;
              Clear DriverId;
              DriverId = inputDS.PSDRV2;
              exsr FormatAndSendJson;
            Endif;

          EndIf;

        enddo;

        *inlr = *on;

        //-----------------------------------------------
        //      FormatAndSendJson;
        //-----------------------------------------------
       begsr FormatAndSendJson;

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

           yajl_addChar('message':%trim(inputDS.PSOMSG));

           If inputDS.PSMPRI <> *Blanks;
             yajl_addChar('priority':%trim(inputDS.PSMPRI));
           Endif;

           if inputDS.PSDLNK <> *blanks;
             yajl_addChar('deeplink_id':%trim(inputDS.PSDLNK));
             yajl_addChar('deeplink_type':'macro');
           endif;

           yajl_beginArray('recipients');
             yajl_addChar(%trim(driverID));
           yajl_endArray();

           yajl_beginObj();
             msgDate = %char(%date():*ISO);
             msgTime = %char(%time():*HMS);
             plttimz(offset);
             msgTimeOff = offset + ':00';
             yajl_addChar('timestamp': UTCFormat);
           yajl_endObj();

           Clear JsonBuild;
           JsonBuild = yajl_copyBufStr();
           yajl_genClose();

           http_setCCSIDs( 1208: 0 );
           HTTP_debug(*on);
           HTTP_SetFileCCSID(1208);

           // Also need code here to set up 'additional headers'
           http_xproc( HTTP_POINT_ADDL_HEADER
                         : %paddr(add_headers) );

           Clear myJson;
           Clear ResponseMessage;
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

       endsr;

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
          pDriverID = inputDS.PSDRV1;
          pDriver2Id = inputDS.PSDRV2;
          pLoadID = *Blanks;
          pTtruckID = inputDS.PSUNIT;
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
