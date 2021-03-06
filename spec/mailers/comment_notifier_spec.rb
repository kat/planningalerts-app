require 'spec_helper'

describe CommentNotifier do
  describe "notify" do
    before :each do
      authority = mock_model(Authority, :full_name => "Foo Council", :email => "foo@bar.gov.au")
      application = mock_model(Application, :authority => authority, :address => "12 Foo Rd", :council_reference => "X/001", :description => "Building something", :id => 123)
      @comment = mock_model(Comment, :email => "foo@bar.com", :name => "Matthew", :application => application, :confirm_id => "abcdef", :text => "It's a good thing.\n\nOh yes it is.", :address => "1 Bar Street")
    end
  
    it "should be sent to the planning authority's feedback email address" do
      notifier = CommentNotifier.notify(@comment)
      notifier.to.should == [@comment.application.authority.email]
    end
    
    it "should have the sender as the main planningalerts email address" do
      notifier = CommentNotifier.notify(@comment)
      notifier.sender.should == "contact@planningalerts.org.au"
    end

    it "should be from the email address of the person who made the comment" do
      notifier = CommentNotifier.notify(@comment)
      notifier.from.should == [@comment.email]
    end

    it "should say in the subject line it is a comment on a development application" do
      notifier = CommentNotifier.notify(@comment)
      notifier.subject.should == "Comment on application X/001"
    end
    
    it "should have specific information in the body of the email" do
      notifier = CommentNotifier.notify(@comment)
      notifier.text_part.body.to_s.should == <<-EOF
For the attention of the General Manager / Planning Manager / Planning Department:

Application:          X/001
Address:              12 Foo Rd
Description:          Building something
Name of commenter:    Matthew
Address of commenter: 1 Bar Street
Email of commenter:   foo@bar.com

It's a good thing.

Oh yes it is.

=============================================================================
This comment was submitted via PlanningAlerts, a free service run by the
OpenAustralia Foundation for the public good.
See http://dev.planningalerts.org.au/applications/123 for more information

http://www.openaustraliafoundation.org.au
=============================================================================
      EOF
    end

    it "should format paragraphs correctly in the html version of the email" do
      notifier = CommentNotifier.notify(@comment)
      notifier.html_part.body.to_s.should == <<-EOF
<h1>For the attention of the General Manager / Planning Manager / Planning Department</h1>
<table>
<tr>
<td>Application</td>
<td>X/001</td>
</tr>
<tr>
<td>Address</td>
<td>12 Foo Rd</td>
</tr>
<tr>
<td>Description</td>
<td>Building something</td>
</tr>
<tr>
<td>Name of commenter</td>
<td>Matthew</td>
</tr>
<tr>
<td>Address of commenter</td>
<td>1 Bar Street</td>
</tr>
<tr>
<td>Email of commenter</td>
<td>foo@bar.com</td>
</tr>
</table>
<h2>Comment</h2>
<p>It's a good thing.</p>

<p>Oh yes it is.</p>
<hr>
<p>
This comment was submitted via PlanningAlerts, a free service run by
<a href="http://www.openaustraliafoundation.org.au">the OpenAustralia Foundation</a>
for the public good.
<a href="http://dev.planningalerts.org.au/applications/123">View this application on PlanningAlerts</a>
</p>
      EOF
    end
  end
end