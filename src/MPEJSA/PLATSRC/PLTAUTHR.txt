     H DftActGrp(*No) ActGrp(*New) BndDir('LIBHTTP/HTTPAPI')
     H FixNbr(*Zoned) Option(*NoDebugIo:*Srcstmt) Debug(*Yes)



      /copy libhttp/qrpglesrc,httpapi_h

      * This program's Procedure Prototype
     Dpltauthr         PR
     D                               30
     D                             1224

      * This program's Procedure Interface
     Dpltauthr         PI
     Dscope                          30
     Dtoken                        1224

     D incoming        PR            10I 0
     D                               10I 0 value
     D                             8192A   options(*varsize)
     D                               10I 0 value
       //?procedure prototypes
     D translate       PR                  ExtPgm('QDCXLATE')
     D   length                       5P 0 const
     D   myJson                   32766A   options(*varsize)
     D   table                       10A   const
     D cpylnk          PR                  ExtPgm('PLCPYLNK')
     D  filename                     10a

     D SDS           ESDS                  EXTNAME(SDS)

     D LeftBracket     C                   U'005b'
     D RightBracket    C                   U'005d'
     D LeftBrace       C                   U'007b'
     D RightBrace      C                   U'007d'
     D Pound           C                   U'0023'
     D Exclamation     C                   U'0021'
     D Comma           C                   U'002c'
     D Pipe            C                   U'007c'

     D filename        s             10a
     D myJSON          S          65535a   varying
     D RC              S             10I 0
     d Server          S            256a
     d UsrAgent        S             64A   Inz(*blanks)
     D nextpos         S             10I 0 inz(1)
     D retdata         S          32766A
     D retlen          S             10I 0
     d ErrDta          S          32766a
     d SavDta          S                   Like(ErrDta)
     D StartPos        S              7  0 INZ(*ZEROS)
     D EndPos          S              7  0 INZ(*ZEROS)
     D secret          S             42a
     D PLBTTRC         DS
     D  REC#                   1      5  0
      //
     D  HLDRC          s              5  0
     C     *DTAARA       DEFINE                  PLBTTRC

        /free
        secret = '"E7vV1kxrRHSLv5owS2P95bF3NFEupCF9cbGm13Zn"';
           myJSON = LeftBrace + ' "client_id": "1000"'
                  + Comma     + ' "client_secret":' + secret
                  + Comma     + ' "grant_type": "client_credentials"'
                  + Comma     + ' "scope":'+scope
                  + RightBrace;


        //  Once you have it in a string, you can send it to the HTTP server.
        //  Use HTTP_setCCSIDs to tell HTTPAPI to trasnlate it to UTF-8 (CCSID 1208),
        //  and then use HTTPAPI's http_post() routine to do the POST operation:
        //
        //

        HTTP_debug(*on);
        http_setCCSIDs( 1208: 0 );

       // Server = %trim('https://mvt.platformscience.com/api/oauth/token');
        Server = %trim('https://mvt.pltsci.com/api/oauth/token');

       //?Send web service request to platform science
       rc=http_url_post_raw(%trim(Server)
                      : %addr( myJSON : *data )
                      : %len( myJSON )
                      : 1
                      : %paddr('INCOMING')
                      : HTTP_TIMEOUT
                      : HTTP_USERAGENT
                      : 'application/json' );

       //?If no error, Convert the data we just received to EBCDIC
       if retlen > 1;
               Translate(retlen: retdata: 'QTCPEBC');
       endif;

          StartPos  = %scan('access_token':retdata);
       if StartPos <> 0;
          StartPos = StartPos + 15;
          EndPos   = (retlen - StartPos) - 1;
        //StartPos = StartPos + 14;
        //EndPos   = (retlen - StartPos);
                       SavDta = %trim(%subst(retdata:StartPos:EndPos));
          token    = %trim(SavDta);
       else;
            IN PLBTTRC;
            HLDRC = rec#;
            filename = %char(hldrc) + 'BT';
            IN *LOCK PLBTTRC;
            rec# = HLDRC  + 1;
            OUT PLBTTRC;
         monitor;
         cpylnk(filename);
         on-error;
         endmon;
       EndIf;
        *inlr = *on;
       //----------------------------------------------------------------------
       //
       //Incoming   - receives the raw data returned in the web service request
       //
       //This procedure is called from within the 'black box' of the 'http_url_
       //Notice the pointer address of the 5th input parameter on the call of '
       //This procedure must be available to the 'black box', but not included
       //therefore it is found here.
       //
       //----------------------------------------------------------------------
     P incoming        B

       //?procedure parameters
     D incoming        PI            10I 0
     D   descriptor                  10I 0 value
     D   myJson                    8192A   options(*varsize)
     D   datalen                     10I 0 value


       //?Make sure we don't overflow the string:
      /FREE
          retlen = (nextpos + datalen) - 1;
          if retlen > %size(retdata);
                  datalen=datalen-(%size(retdata)-retlen);
          endif;

         //  If there is nothing to write, return THAT...
          if datalen < 1;
                  return 0;
          endif;

         //  Here we add any data sent to the end of our 'retdata' string:
          %subst(retdata: nextpos) =
            %subst(myJson:1:datalen);
          nextpos = nextpos + datalen;

         //  We always return the amount of data that we wrote.   Note
         //   that if http-api sees that we didn't write as much data as
         //   it sent us, it'll abort the process with an error message.
          return datalen;
      /END-FREE
     P                 E
