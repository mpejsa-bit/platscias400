       subject  = 'This is a plain text message';
       body   = 'This is a plain text message';
       recipient = '7043098401@vtext.com';


       CmdStr = 'SNDSMTPEMM RCP(' +
            Quote + %trim(recipient) +
            Quote + ') ' +
           'SUBJECT(' + Quote + %trim(subject) + Quote + ') ' +
           'NOTE(' + Quote + %trim(body) + Quote + ')' +
           ' CONTENT(*HTML)';


       Callp Run(Cmdstr:%Size(CmdStr));


       *inlr = *on;
