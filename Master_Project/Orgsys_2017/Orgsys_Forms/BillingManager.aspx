<%@ Page Title="" Language="C#" MasterPageFile="~/Orgsys_Forms/Master/Internal.Master" AutoEventWireup="true" CodeBehind="BillingManager.aspx.cs" Inherits="Orgsys_2017.Orgsys_Forms.BillingManager" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script src="Internal_Forms/JSFiles/BillingManager.js"></script>
    <script>
        /*Created By     : Marie Gougeon
          Created Date   : 2018-07-18
          Description    : MAIN BILLING PAGE
          Revised        : September 20th 2018
        */

        var token = '<%= token %>';
        window.getApi = "<%= get_api %>";
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div id="page-wrapper">
        <div id="banner-container" class="osp-heading panel-heading narrow-container">
            <div id="welcome-container" class="osp-heading panel-heading">
                <h4 id="welcome-header" class="osp-heading panel-heading">Billing Manager</h4>
            </div>
            <div id="logo-container" class="osp-heading panel-heading"></div>
        </div>
        <div class="create_new_billing">
            <div class="new_billing_button_container">
                <div class="form-group new_billing_button">
                    <a id="newBilling-swal" data-toggle="tooltip" title="Create a new billable or non-billable item. It can be claim related or internal. " class="btn btn-info">
                        <i class="icon-plus">Add Billing Item</i>
                    </a>
                </div>
            </div>
        </div>
        <div class="main-wrapper">
            <div class="row margin_bottom">
                <div class="col-md-3">
                    <label for="ddlBillType">Bill Type</label>
                    <select class="form-control" id="ddlBillType">
                        <option value="1">Billable</option>
                        <option value="2">Non Billable</option>
                    </select>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <table id="tblBills" class="table table-bordered table-striped table-hover dataTable no-footer">
                        <thead>
                            <tr>
                                <th>Actions</th>
                                <th>Date</th>
                                <th>Date Added</th>
                                <th>Date Complete</th>
                                <th>Client</th>
                                <th>Duration</th>
                                <th>Method</th>
                                <th>Reason</th>
                                <th>Assigned To</th>
                            </tr>
                        </thead>
                    </table>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
