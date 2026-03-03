      *-----------------------------------------------------
      * Journal Receiver Header Data Structure
      *-----------------------------------------------------
     D jHdrDs          ds                  based(jHdrDsPtr)
     D  jHdrBytRtn                    9b 0
     D  jHdrOfsEnt                    9b 0
     D  jHdrNbrEnt                    9b 0
     D  jHdrCntHnd                    1a
      *-----------------------------------------------------
      * Journal Receiver RJNE0100 Data Structure
      *-----------------------------------------------------
     D j100Ds          ds                  based(j100DsPtr)
     D  j100OfsNxJH                   9b 0
     D  j100OfsNlIn                   9b 0
     D  j100OfsData                   9b 0
     D  j100PtrHndl                   9b 0
     D  j100Seq                      20a
     D  j100Code                      1a
     D  j100Type                      2a
     D  j100TimeStmp                 26a
     D   j100Date                    10a   overlay(j100TimeStmp:1)
     D   j100Time                    15a   overlay(j100TimeStmp:12)
     D  j100Jobn                     10a
     D  j100Jobu                     10a
     D  j100Job#                      6a
     D  j100Pgmn                     10a
     D  j100Objn                     30a
     D  j100Rrn                      10a
     D  j100Flg                       1a
     D  j100CmId                     20a
     D  j100UsrPrf                   10a
     D  j100SysN                      8a
     D  j100JrnId                    10a
     D  j100RefCns                    1a
     D  j100Trg                       1a
     D  j100InCmp                     1a
     D  j100ObnId                     1a
     D  j100IgnFlg                    1a
     D  j100MinEn                     1a
      *-----------------------------------------------------
      * Journal Receiver Null Value Varlen Data Structure
      *-----------------------------------------------------
     D jNlvDs          ds                  based(jNlvDsPtr)
     D  jNlvlLen                      9b 0
     D  jNlvInd                    1024a
      *-----------------------------------------------------
      * Journal Receiver Null Value Data Structure
      *-----------------------------------------------------
     D jNulDs          ds                  based(jNulDsPtr)
     D  jNulInd                    1024a
      *-----------------------------------------------------
      * Journal Receiver Entry Specific Data Structure
      *-----------------------------------------------------
     D jEntDs          ds                  based(jEntDsPtr)
     D  jEntlLen                      5a
     D  jEntRsvd                     11a
     D  jEntData                   2048a
