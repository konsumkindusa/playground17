@istest
public class MultiAttachmentTestController{

    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();
    
    public static testMethod void testController()
    {
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //create Test Case
        Case cse = TestDataBuilder.buildTestCase('open');
        insert cse;
        
        //set current page and controller
    	Pagereference pref = Page.cp_case_attachfile;
    	pref.getParameters().put('Id', cse.Id);
		pref.getParameters().put('cc', 'jp');//HW
    	Test.setCurrentPage(pref);
        
        MultiAttachmentController controller=new MultiAttachmentController();
        controller.sobjId= cse.id;
        
        System.assertEquals(0, controller.getAttachments().size());
        
        System.assertEquals(1, controller.newAttachments.size());
        
        controller.addMore();
        
        System.assertEquals(1 + MultiAttachmentController.NUM_ATTACHMENTS_TO_ADD, controller.newAttachments.size());
        
        
        List<Attachment> newAtts=controller.newAttachments;
        newAtts[0].Name='Unit Test 1';
        newAtts[0].Description='Unit Test 1';
        newAtts[0].Body=Blob.valueOf('Unit Test 1');
        newAtts[0].ContentType= 'text/plain; charset=UTF-8';

        newAtts[1].Name='Unit Test 2';
        newAtts[1].Description='Unit Test 2';
        newAtts[1].Body=Blob.valueOf('Unit Test 2');
        newAtts[1].ContentType = 'text/plain; charset=UTF-8';
        
        
        controller.save();
        
        //HW, 2016.8.1, 1578527
        list<Task> lstTask = [select id from task where whatId =: cse.Id];
        System.assertEquals(1, lstTask.size());
        //1578527
        
        System.assertEquals(2, controller.getAttachments().size());
        System.assertNotEquals(null, controller.done());
    }
}