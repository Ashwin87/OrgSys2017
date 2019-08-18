﻿using Orgsys_2017.Orgsys_Classes;
using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Web;
using System.Web.Security;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Orgsys_2017.Orgsys_Forms.Master
{
    public partial class Internal : System.Web.UI.MasterPage
    {
        private static readonly HttpClient client = new HttpClient();
        public class page: Orgsys_2017.Orgsys_Classes.OSI_Page { }

        protected string token;
        protected string api = OSI_Page.get_api;

        protected void Page_Load(object sender, EventArgs e)
        {

            if (!string.IsNullOrEmpty(Session["token"] as string))
            {
                token = HttpContext.Current.Session["token"].ToString();
            }
            else
            {
                Response.Redirect("~/Orgsys_Forms/Orgsys_Login.aspx?logout=InvalidAspSession");
            }

            using (var client = new HttpClient())
            {
                if (token != null)
                {
                    var response = client.PostAsync(api + "/api/session/SessionTracker/" + token + "/" + true, null);
                    if (response.Result.StatusCode == HttpStatusCode.Unauthorized)
                    {
                        Response.Redirect("~/Orgsys_Forms/Orgsys_Login.aspx?logout=Kicked");
                    }
                }
                else
                {
                    Response.Redirect("~/Orgsys_Forms/Orgsys_Login.aspx?logout=Kicked");
                }

            }
            if (Page.IsPostBack)
            {

            }
        }

        
        protected void Logout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Cache.SetExpires(DateTime.UtcNow.AddMinutes(-1));
            Response.Cache.SetCacheability(HttpCacheability.NoCache);
            Response.Cache.SetNoStore();

            try
            {
                Session.Abandon();
                FormsAuthentication.SignOut();
                Response.Cache.SetCacheability(HttpCacheability.NoCache);
                Response.Buffer = true;
                Response.ExpiresAbsolute = DateTime.Now.AddDays(-1d);
                Response.Expires = -1000;
                Response.CacheControl = "no-cache";

            } catch(Exception ex) {
                ExceptionLogger.LogException(ex);

            }
    Response.Redirect("/Orgsys_Forms/Orgsys_Login.aspx");
        }
    }
    

}