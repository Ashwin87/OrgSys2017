
 SELECT Claim_Documents.DocName AS DocName, Claim_Documents.Timestamp AS Timestamp, Claim_Documents.ClaimRefNu AS ClaimRefNu, Claim_Documents.DocExt AS DocExt, Claim_Documents.DocID AS DocID, List_Claim_Document_Types.Type AS DocumentDescr, User_Profiles.EmpFirstName AS EmpFirstName
 FROM Claim_Documents  
 LEFT JOIN [Session] ON [Session].SessionToken = 'rS3FeAMgWDFPhgmNcmlGss'   
 LEFT JOIN [User_Profiles] ON [Session].UserID = [User_Profiles].UserID  
 LEFT JOIN [User_Role] ON [User_Profiles].UserID = [User_Role].UserID
 LEFT JOIN [Client] ON [User_Profiles].ClientID = [Client].ClientID  
 LEFT JOIN List_Claim_Document_Types ON Claim_Documents.DocumentDescrID = List_Claim_Document_Types.DocumentTypeID 
 WHERE  Client.ClientID = [Session].ClientID 
 AND EXISTS (SELECT[User_FileType_Permission].Id FROM[User_FileType_Permission] 
				WHERE[User_FileType_Permission].FileTypeID = Claim_Documents.DocumentDescrID 
				AND[User_FileType_Permission].RoleID =[User_Role].Role_ID) 





