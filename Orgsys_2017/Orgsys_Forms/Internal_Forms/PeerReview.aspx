<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PeerReview.aspx.cs" MasterPageFile="~/Orgsys_Forms/Master/Internal.Master" Inherits="Orgsys_2017.Orgsys_Forms.Internal_Forms.PeerReview" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script>

</script>
    <style>
        /* The switch - the box around the slider */
        .switch {
            position: relative;
            display: inline-block;
            width: 45px;
            height: 20px;
        }

            /* Hide default HTML checkbox */
            .switch input {
                opacity: 0;
                width: 0;
                height: 0;
            }

        /* The slider */
        .slider {
            position: absolute;
            cursor: pointer;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: #ccc;
            -webkit-transition: .4s;
            transition: .4s;
        }

            .slider:before {
                position: absolute;
                content: "";
                height: 15px;
                width: 15px;
                left: 3px;
                bottom: 3px;
                background-color: white;
                -webkit-transition: .4s;
                transition: .4s;
            }

        input:checked + .slider {
            background-color: #2196F3;
        }

        input:focus + .slider {
            box-shadow: 0 0 1px #2196F3;
        }

        input:checked + .slider:before {
            -webkit-transform: translateX(26px);
            -ms-transform: translateX(26px);
            transform: translateX(26px);
        }

        /* Rounded sliders */
        .slider.round {
            border-radius: 34px;
        }

            .slider.round:before {
                border-radius: 50%;
            }
    </style>
    <script src="JSFiles/PeerReview.js"></script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="panel panel-custom-big-default">
        <div id="banner-container" class="osp-heading panel-heading narrow-container">
            <div id="welcome-container">
                <h3 id="welcome-header" class="osp-heading panel-heading">Peer Review</h3>
                <label for="chkPrAvailable">Available for Peer Reviews</label>
                <label class="switch">
                    <input type="checkbox" id="chkPrAvailable" />
                    <span class="slider round"></span>
                </label>
            </div>
        </div>
        <div class="panel-body remove-top-border well" id="userReviews">
            <h4>Reviews assigned to you</h4>
            <table style="width: 100%;" id="tblAssignedReviews" class="table table-bordered table-striped table-hover dataTable no-footer">
                <thead>
                    <tr>
                        <th style="width: 20px"></th>
                        <th style="width: 20px">Reference #</th>
                        <th style="width: 20px">User Submited</th>
                        <th style="width: 20px">Date Opened</th>
                        <th style="width: 20px">Client</th>
                        <th style="width: 20px">Employee Last</th>
                        <th style="width: 20px">Change Comments</th>
                    </tr>
                </thead>
            </table>
        </div>
        <div class="panel-body remove-top-border well" id="beingReviewed">
            <h4>Your updates being reviewed</h4>
            <table style="width: 100%;" id="tblOutgoingReviews" class="table table-bordered table-striped table-hover dataTable no-footer">
                <thead>
                    <tr>
                        <th style="width: 20px">Reference #</th>
                        <th style="width: 20px">User Assigned</th>
                        <th style="width: 20px">Date Opened</th>
                        <th style="width: 20px">Client</th>
                        <th style="width: 20px">Employee</th>
                    </tr>
                </thead>
            </table>
        </div>
        <div class="panel-body remove-top-border well" id="returnedReviews">
            <h4>Reviews that need changes</h4>
            <table style="width: 100%;" id="tblReturnedReviews" class="table table-bordered table-striped table-hover dataTable no-footer">
                <thead>
                    <tr>
                        <th style="width: 20px"></th>
                        <th style="width: 20px">Reference #</th>
                        <th style="width: 20px">User Assigned</th>
                        <th style="width: 20px">Date Opened</th>
                        <th style="width: 20px">Client</th>
                        <th style="width: 20px">Employee</th>
                    </tr>
                </thead>
            </table>
        </div>
        <div class="panel-body remove-top-border well" id="pendingReviews">
            <h4>Pending reviews</h4>
            <table style="width: 100%;" id="tblPendingReviews" class="table table-bordered table-striped table-hover dataTable no-footer">
                <thead>
                    <tr>
                        <th style="width: 20px"></th>
                        <th style="width: 20px">Reference #</th>
                        <th style="width: 20px">User Submited</th>
                        <th style="width: 20px">Date Opened</th>
                        <th style="width: 20px">Client</th>
                        <th style="width: 20px">Employee</th>
                    </tr>
                </thead>
            </table>
        </div>
    </div>
</asp:Content>
