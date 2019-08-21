<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PeerReviewClaimUpdate.aspx.cs" MasterPageFile="~/Orgsys_Forms/Master/Internal.Master" Inherits="Orgsys_2017.Orgsys_Forms.Internal_Forms.PeerReviewClaimUpdate" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script src="JSFiles/PeerReviewUpdatesandBilling.js"></script>
    <script src="JSFiles/SaveUpdates.js"></script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">






    <div class="panel panel-custom-big-default">
        <div id="banner-container" class="osp-heading panel-heading narrow-container">
            <div id="welcome-container" class="osp-heading panel-heading">
                <h4 id="welcome-header" class="osp-heading panel-heading">Peer Review - Claim Updates and Billing</h4>
                <button class="btn btn-success" id="btnBackPeerReview">Back to peer review dashboard</button>
            </div>
            <div id="logo-container" class="osp-heading panel-heading"></div>
        </div>
        <div class="osp-heading panel-heading narrow-container">
            <div class="well">
                <div class="row">
                    <div class="col-md-4">
                        <label for="hDateOpened">Date Opened</label>
                        <input type="text" readonly="readonly" class="form-control" id="hDateOpened" />

                        <label for="hClaimRefNo">Claim Reference Number</label>
                        <input type="text" readonly="readonly" class="form-control" id="hClaimRefNo" />

                        <label for="hUserSubmited">User Submited</label>
                        <input type="text" readonly="readonly" class="form-control" id="hUserSubmited" />
                    </div>
                    <div class="col-md-4">
                        <label for="hClient">Client</label>
                        <input type="text" readonly="readonly" class="form-control" id="hClient" />

                        <label for="hEmployeeLast">Employee</label>
                        <input type="text" readonly="readonly" class="form-control" id="hEmployeeLast" />

                    </div>
                    <div class="col-md-4">
                        <label for="hReviewComments">Review Comments</label>
                        <textarea class="form-control" name="reviewComments" id="hReviewComments" rows="4" readonly="readonly"></textarea>
                        <button id="btnAddComments" class="btn btn-success" style="display: none; float: right; margin-top: 5px;">Add Comments</button>
                    </div>
                </div>
            </div>
        </div>
        <ul class="nav nav-tabs">
            <li class="active"><a data-toggle="tab" href="#ClaimUpdates">Claim Update</a></li>
            <li style="display: none" id="cmrtab"><a data-toggle="tab" href="#CMRTab" >CMR</a></li> <%--hide if no cmr--%>
            <li style="display: none" id="filesTab"><a data-toggle="tab" href="#FilesTab" >Files</a></li> <%--hide if no files--%>
        </ul>

        <div class="tab-content">
            <div id="ClaimUpdates" class="tab-pane fade in active">
                <div class="panel-body remove-top-border">
                    <div id="UpdatesForm">
                        <div id="Updates" class="div-left">
                            <div class="row margin_bottom">
                                <div class="col-md-6 form-group">
                                    <label>Action Type</label>
                                    <input class="form-control" id="ActionType" readonly="readonly" />
                                </div>
                                <div class="col-md-6">
                                    <label>Date</label>
                                    <input data-toggle="tooltip" title="Select a date not in the future or more than 2 days prior." class="form-control col-md-3" name="updatesDate" id="UpdatesDate" readonly="readonly" required />
                                </div>
                            </div>
                   
                            <div class="row margin_bottom">
                                <div class="form-group col-md-12">
                                    <label>Internal Comments</label>
                                    <textarea class="form-control" name="Comments" id="InternalComments" rows="4" required=""></textarea>
                                </div>
                            </div>
                            <div class="row margin_bottom">
                                <div class="form-group col-md-12">
                                    <label>Reported Comments</label>
                                    <textarea class="form-control" name="Comments" id="ReportedComments" rows="4"></textarea>
                                </div>
                            </div>
                            <div class="row margin_bottom">
                                <div class="form-group col-md-12">
                                    <label>Comments to Employee </label>
                                    <textarea class="form-control" name="Comments" id="EmployeeComments" rows="4"></textarea>
                                </div>
                            </div>
                            <div class="row margin_bottom">
                                <button type="button" id="btnSavePRUpdates" class="btn btn-success">Save Updates</button>
                            </div>
                        </div>
                        <!--Billing Details-->
                        <div id="UpdatesBilling" class="div-right pull-right">
                            <div class="row margin_bottom">
                                <div class="form-group col-md-6">
                                    <label>Duration (minutes)</label>
                                    <input data-toggle="tooltip" title="How long did the update take?" type="text" class="form-control col-md-3 validRequired" name="ClientBillDuration" id="ClientBillDuration" required />
                                </div>

                            </div>
                            <div class="row">
                                <div class=" col-md-12">
                                    <label class="checkbox-inline">
                                        <input type="checkbox" name="inlineRadioOptions" id="billable" value="Billable" />Billable
                                    </label>
                                    <label class="checkbox-inline">
                                        <input type="checkbox" name="inlineRadioOptions" id="directcontact" value="Direct Contact" />Direct Contact
                                    </label>
                                    <label class="checkbox-inline">
                                        <input type="checkbox" name="inlineRadioOptions" id="postage" value="Postage" />Postage
                                    </label>
                                    <label class="checkbox-inline">
                                        <input type="checkbox" name="inlineRadioOptions" id="courier" value="Courier" />Courier
                                    </label>
                                      <label class="checkbox-inline">
                                        <input type="checkbox" name="inlineRadioOptions" id="SeniorConsulting" value="Senior Consulting" />Senior Consulting
                                    </label>
                                </div>
                            </div>
                            <div class="row margin_bottom">
                                <div class="col-md-12 form-group">
                                    <label>Method</label>
                                    <select data-toggle="tooltip" title="Billing Method" class="populateBillingMethodwithID form-control validRequired" name="BillingMethod" id="BillingMethod">
                                        <option value="">--Select--</option>
                                    </select>
                                </div>
                                <div class="col-md-12 form-group">
                                    <label>Reason</label>
                                    <select data-toggle="tooltip" title="Billing Reason" class="populateBillingReason form-control validRequired" name="BillingReason" id="BillingReason">
                                        <option value="">--Select--</option>
                                    </select>
                                </div>
                            </div>
                            <div class="row margin_bottom">
                                <div class="form-group col-md-12">
                                    <label>Billable Comments</label>
                                    <textarea class="form-control validRequired" name="Comments" id="ClientBillComments" rows="4"></textarea>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div id="CMRTab" class="tab-pane fade">
                <div id="CMR">

                </div>
                <div class="row margin_bottom">
                    <button type="button" id="btnSavePrCMR" class="btn btn-success">Save CMR Update</button>
                </div>
            </div>
            <div id="FilesTab" class="tab-pane fade">
                <div class="row margin_bottom">
                    <div class="form-group col-md-12">
                        <table style="width:100%;" id="tblClaimUpdateFiles" class="table table-bordered table-striped table-hover dataTable no-footer">
                            <thead>
                            <tr>
                                <th></th>
                                <th>FileName</th>
                            </tr>
                            </thead>
                            <tbody></tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

</asp:Content>
