     **Free
       Ctl-opt option(*srcstmt:*nodebugio);
       Ctl-opt dftactgrp(*no) actgrp(*caller);

       Dcl-s Body Char(200);
       Dcl-s Command Char(200);
       Dcl-s MessageText varchar(32740);
       Dcl-s MessageLength int(5);
       Dcl-s ResponseMsg Varchar(9999);
       Dcl-s ResponseHeader Varchar(1000);
       Dcl-s ResponsePos Packed(4);
       Dcl-s ReturnedSQLCode char(5);
       Dcl-s Tokenheader Char(500);

       Dcl-s Ind_Err Ind;

       Dcl-c Fail const('FAIL');
       Dcl-c Pass const('PASS');
       Dcl-c SQL_OK const('00000');
       Dcl-c Rcd const('Record Not Found');
       Dcl-c TokenKey const('Bearer *******************');
       Dcl-c Url const('https://gorest.co.in/public-api/users');

       Dcl-pr system zoned(10:0) extproc('system');
         szcmd pointer Value Options(*String);
       End-pr;

       Dcl-Pr POSTCLOBV extpgm('POSTCLOBV');
         email  char(30);
         name   char(25);
         gender char(10);
         status char(10);
       End-Pr;

       Dcl-pi POSTCLOBV;
         email  char(30);
         name   char(25);
         gender char(10);
         status char(10);
       End-pi;

       Dcl-s CPFMSGID char(7) import('_EXCP_MSGID');

       //***********************************************************************
       // MainLine
       //***********************************************************************
         *inlr = *on;

         Exec sql set option commit = *none;

         SetEnvironment();
         ProcessApi();

       //***********************************************************************
       // SetRequest - Set the web service variables
       //***********************************************************************
         Dcl-proc SetEnvironment;

           Exec sql CALL QSYS2.QCMDEXC('CHGJOB CCSID(37)');
           Tokenheader = '<httpHeader>'              +
                     '<header name="Authorization" value="' +
                          %trim(TokenKey) + '">'+
                     '</header>'                     +
                     '<header name="Content-Type" value="application/json">' +
                     '</header>'                     +
                     '</httpHeader>';


           Body = '{' + '"email":' + '"' + %trim(email)   + '",' +
                       '"name":'  + '"' + %trim(name)    + '",' +
                       '"gender":' + '"' + %trim(gender)  + '",' +
                       '"status":'+ '"' + %trim(status)  + '"' + '}';

         End-proc;
       //***********************************************************************
       // ProcessApi - Send Post Request And Fetch Data
       //***********************************************************************
         Dcl-proc ProcessApi;

           Exec sql
            Select Coalesce(Varchar(ResponseMsg,9999),' '),
                   Varchar(ResponseHttpHeader,1000) into :ResponseMsg,
                                                         :ResponseHeader
            From Table(Systools.HttpPostClobVerbose(Trim(:Url),
                                                    Trim(:Tokenheader),
                                                    Trim(:body)))
                                                    as InternalServices;

           Diagnostics();
           if ReturnedSqlCode = SQL_OK or ReturnedSqlCode = *Blanks;
             dsply 'Okay response with httpPostClobVerbose';

             exec sql drop table if exists qtemp/WkTestFile;
             exec sql create table qtemp/WkTestFile(data char(9999));
             exec sql insert into qtemp/WkTestFile(data)
                                     values(:ResponseMsg);

             dsply 'Check WkTestFile file in Qtemp for data';
           endIf;

         End-proc;
       //***********************************************************************
       // Diagnostics - get sql details
       //***********************************************************************
         Dcl-proc Diagnostics ;

           Exec sql GET DIAGNOSTICS CONDITION 1
             :ReturnedSqlCode = DB2_RETURNED_SQLCODE,
             :MessageLength = MESSAGE_LENGTH,
             :MessageText = MESSAGE_TEXT;

         End-proc ;

