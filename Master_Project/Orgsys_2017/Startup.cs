using Microsoft.Owin;
using Owin;

[assembly: OwinStartupAttribute(typeof(Orgsys_2017.Startup))]
namespace Orgsys_2017
{
    public partial class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            ConfigureAuth(app);
        }
    }
}
