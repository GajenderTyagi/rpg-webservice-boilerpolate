      **************************************************************************
      * PROJECT/TASK.:                                                         *
      *                                                                        *
      * CREATED BY...: PROGRAMMERS.IO                                          *
      * DESCRIPTION..:                                                         *
      *                                                                        *
      *                                                                        *
      * M O D I F I C A T I O N S                                              *
      * USER          PROJ#           DATE           DESCRIPTION               *
      **************************************************************************
      **Free
        ctl-opt option(*srcstmt:*nodebugio);
        ctl-opt dftActgrp(*no) actGrp(*caller);

        /copy qrpglesrc,POSTCLOB_C

        dcl-pr postClob_t extpgm('POSTCLOB_T');
          emailId  like(email);
          fullName like(name);
          gender1 like(gender);
          status1 like(status);
        end-pr;

        dcl-pi postClob_t;
          emailId  like(email);
          fullName like(name);
          gender1  like(gender);
          status1  like(status);
        end-pi;
        //***********************************************************************
        // MainLine
        //***********************************************************************
        *inlr = *on;

        POSTCLOBV(emailId:fullName:gender1:status1);
