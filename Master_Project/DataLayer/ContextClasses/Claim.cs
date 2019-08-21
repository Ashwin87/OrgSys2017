
namespace DataLayer
{
    partial class Claim
    {
        partial void OnCreated()
        {
            if (this.ClientID == 0)
                this.ClientID = 1003;
        }
        //I would have to do a default value for the Archived.
    }
}
