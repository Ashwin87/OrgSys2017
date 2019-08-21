<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="Slide.ascx.cs" Inherits="Orgsys_2017.Orgsys_Forms.Slides.Slide" %>
<section  class="pdf-page" id="@@ControlId">
    <div class="container">
        <div class="panel panel-default">
            <div class="panel-heading">
                <h4><i class="icon icon-calendar"></i></h4>
            </div>
            <div class="panel-body ">
                <div class="row">
                    <div class="col-5 p-5">
                        <div class="pdf-control"></div>
                        <textarea onblur="ExecutiveSummaryViewModel.UpdateLabelValue(this)" class="form-control ui-control" id="@@EditorId" controlType="Slide"> </textarea>
                    </div>
                </div>
                <div class="row p-3 text-right">
                    <button class="btn btn-primary float-right ml-2 ui-control" onclick="ExecutiveSummaryViewModel.addSlide(this)" controltype="Slide"><span class="icon icon-plus"></span></button>
                    <button class="btn btn-warning float-right ui-control" onclick="ExecutiveSummaryViewModel.removeSlide(this)" controltype="Slide"><span class="icon icon-bin"></span></button>
                </div>
            </div>
        </div>
    </div>
</section>

