using DataLayer;
using Newtonsoft.Json;
using Orgsys_2017.Orgsys_Classes;
using System;
using System.Collections.Generic;
using System.Net;
using System.Net.Mail;
using System.Web.Http;
using System.Configuration;
using Swashbuckle.Swagger.Annotations;
using APILayer.Controllers.Auth.Authentication;
using APILayer.Controllers.Auth.SwaggerFilters;

namespace APILayer.Controllers
{
    /* Created By   : Sam Khan
    Create Date  : 2017 -06-13
    Description  : It sends the emails automatically 
    */
    [OSIAuthenticationFilter]
    [SwaggerOperationFilter(typeof(OSITokenHeader))]
    [RoutePrefix("api/Email")]
    public class EmailController : ApiController
    {
        OrgSys2017DataContext context = new OrgSys2017DataContext(ConfigurationManager.ConnectionStrings["OrgsysConnectionString"].ConnectionString);

        public void Post(string token,[FromBody]string emailData)
        {
            SmtpClient smtp = new SmtpClient();
            MailMessage mm;
            try
            {
                if (emailData.Length > 0)
                {
                    //Deserialzing Email Objects
                    EmailDetail email = JsonConvert.DeserializeObject<EmailDetail>(emailData.ToString());

                    smtp.UseDefaultCredentials = false;
                    smtp.DeliveryMethod = SmtpDeliveryMethod.Network;
                    smtp.Credentials = new NetworkCredential("noreply", "44bananas55$");
                    smtp.Host = "connect.orgsoln.com"; //Change for smtp from OSI
                    smtp.EnableSsl = false;
                    smtp.Port = 25;

                    mm = new MailMessage("noreply@orgsoln.com", email.emailData.To);
                    mm.Subject = email.emailData.Subject;
                    mm.IsBodyHtml = true;
                    mm.Body = email.emailData.Body;
                   

                    if (email.emailData.AttachmentPaths != null)
                    {
                        foreach (var path in email.emailData.AttachmentPaths)
                        {
                            mm.Attachments.Add(new Attachment(path));
                        }
                    }
                    
                    smtp.Send(mm);
                    smtp.Dispose();
                }
            }
            catch (Exception ex)
            {
                EmailDetail email = JsonConvert.DeserializeObject<EmailDetail>(emailData.ToString());

                if (token != null)
                {
                    InsertEmail(Convert.ToInt32(context.GetUserIDSession(token)), Convert.ToInt32(context.GetClientIDBySession(token)), email.emailData.ClaimID, email.emailData.From, email.emailData.To, email.emailData.Subject, email.emailData.Body, 1);
                }
                else
                {
                    InsertEmail(0, 0, 0, email.emailData.From, email.emailData.To, email.emailData.Subject, email.emailData.Body, 1);

                }
                ExceptionLog.LogException(ex);
            }
        }

        public void InsertEmail(int userID, int clientID, int claimID, string senderAddress, string recipientAddress, string subjectValue, string content, int ishtml)
        {
            try
            {
                context.InsertEmail(userID, clientID, claimID, senderAddress, recipientAddress, subjectValue, content, ishtml);
            }
            catch (Exception ex)
            {
                ExceptionLog.LogException(ex);
            }
        }


        public class EmailDetail
        {
            public Email emailData { get; set; }
        }
        public class Email
        {
            public int ClaimID { get; set; }
            public string To { get; set; }
            public string From { get; set; }
            public string Subject { get; set; }
            public string Body { get; set; }
            public List<string> AttachmentPaths { get; set; }
        }

    }
}
