using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Orgsys_2017
{
    public partial class _Default : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            Server.Transfer("\\Orgsys_Forms\\Orgsys_Login.aspx", true);
        }
    }
}