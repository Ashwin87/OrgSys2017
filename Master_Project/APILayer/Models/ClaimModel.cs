using DataLayer;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;

namespace APILayer.Models
{
    public class ClaimModel
    {
        string claimRef;
        string newClaimRef;
        int count = 1;
        OrgSys2017DataContext context = new OrgSys2017DataContext();

        public void ArchiveClaim(string claimRef)
        {
            //on claim updating, archiving is done after update submission so this query will return many.
            //skips the newest version of the claim(largest ClaimID) /abovtenko
            var query = (from q in context.Claims
                         where q.ClaimRefNu == claimRef && q.Archived == false
                         orderby q.ClaimID descending
                         select q).Skip(1);

            if (query.Count() > 0)
            {
                //archive remaining claims
                foreach (var claim in query)
                {
                    claim.Archived = true;
                }

                context.SubmitChanges();
            }

        }
        public string UniqueClaimReference(string ClientID)
            {
            while (count > 0)
            {
                newClaimRef= GenerateClaimReference(ClientID);
                
                    count = context.Claims.Where(x => x.ClaimRefNu == claimRef).Count();

            }
            return newClaimRef;
        }
        private string GenerateClaimReference(string ClientID)
        {
           
            var random = new Random();
            var strArray = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
            var charArray = new char[8];
            for (int i = 0; i < charArray.Length; i++)
            {
                charArray[i] = strArray[random.Next(strArray.Length)];
            }

            claimRef = new string(charArray);
           
            return claimRef;


        }
       
    }
}