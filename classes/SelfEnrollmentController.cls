/**
 * @author          Pranav Raulkar
 * @date            26/03/2016
 * @description     This class houses utility methods for the Mathworks TAH module.
 *                  A valid enrollment code is one where - 
 *                  a.  Of same length as specified in enrollment code configuration setting
 *                  b.  Status__c = Active
 *                  c.  Associated with an ETA which is Active
 * @revision        1.0 - Initial version
 */
public without sharing class SelfEnrollmentController {
    /* Public variables section */
    public Enrollment_Code__c eCode                 { get; set; }

    public String letsGetStartedLink                { get; set; }
    public String language                          { get; set; }
    public String enrollmentCode                    { get; set; }

    public Boolean isNonExistentEnrollmentCode      { get; set; }
    public Boolean isInactiveEtaCode                { get; set; }
    public Boolean isEnrollmentCodeRevoked          { get; set; }
    public Boolean isValidEnrollmentCode            { get; set; }

    /*
        @author         Pranav Raulkar
        @date           26/03/2016
        @description    Constructor method. Initializes all the variables on page load and performs
                        a onload enrollment code validation if an enrollment code is embedded in the
                        page URL.
    */
    public SelfEnrollmentController() {
        initializeVars();
        readURLParams();
        fetchEnrollmentCodeRecord();
        setPageLanguage();
        validateEnrollmentCode(eCode);
    }

    /*
        @author         Pranav Raulkar
        @date           13/04/2016
        @description    Method to initialize the class variables
    */
    private void initializeVars() {
        Logger.push('SelfEnrollmentController', 'initializeVars');
        
        isNonExistentEnrollmentCode = false;
        isInactiveEtaCode = false;
        isEnrollmentCodeRevoked = false;
        isValidEnrollmentCode = false;
        
        Logger.pop();
    }

    /*
        @author         Pranav Raulkar
        @date           13/04/2016
        @description    Method to initialize the class variables
    */
    private void readURLParams() {
        Logger.push('SelfEnrollmentController', 'readURLParams');

        // Get the code from URL
        enrollmentCode = ApexPages.currentPage().getParameters().get(TrainingUtil.ECODE_URL_PARAM_KEY);

        // Get the language from URL
        language = ApexPages.currentPage().getParameters().get(TrainingUtil.LANGUAGE_URL_PARAM_KEY);

        Logger.pop();
    }

    /*
        @author         Pranav Raulkar
        @date           13/04/2016
        @description    Method to initialize the class variables
    */
    private void fetchEnrollmentCodeRecord() {
        Logger.push('SelfEnrollmentController', 'fetchEnrollmentCodeRecord');

        // Get the enrollment code from database
        eCode = TrainingUtil.getEnrollmentCode(enrollmentCode); 

        Logger.pop();
    }

    /*
        @author         Pranav Raulkar
        @date           13/04/2016
        @description    Deduce the language code that needs to be used for the page
    */
    private void setPageLanguage() {
        Logger.push('SelfEnrollmentController', 'setPageLanguage');

        if(String.isEmpty(language) && eCode != null) {
            // If the language from URL is empty and we have a enrollment code, get ETA language
            language = eCode.Enterprise_Training_Agreement__r.Language__r.SF_ISO_Code__c;

            if(String.isEmpty(language)) {
                // If there is no language code from URL or ETA, set default to English
                language = TrainingUtil.DEFAULT_LANGUAGE_CODE;
            }
        } else if(!String.isEmpty(language) && !TrainingUtil.doesLanguageExist(language)) {
            // If there is no language code from URL or ETA, set default to English
            language = TrainingUtil.DEFAULT_LANGUAGE_CODE;
        }

        Logger.pop();
    }

    /*
        @author         Pranav Raulkar
        @date           26/03/2016
        @description    The method performs the enrollment code validation as per following -
                        1.  Check if enrollment code exists.
                        2.  Check if the enrollment code is valid (code active)
                        3.  Check if enrollment code's ETA is active
                        4.  Check if enrollment code is revoked
    */
    public void validateEnrollmentCode(Enrollment_Code__c eCode) {
        Logger.push('SelfEnrollmentController', 'validateEnrollmentCode');

        TrainingUtil.ValidationStatus status = TrainingUtil.validateEnrollmentCode(eCode);
        
        if(status == TrainingUtil.ValidationStatus.NON_EXISTENT) {
            isNonExistentEnrollmentCode = true;
        } else if(status == TrainingUtil.ValidationStatus.VALID) {
            isValidEnrollmentCode = true;
        } else if(status == TrainingUtil.ValidationStatus.INACTIVE_ETA_CODE) {
            isInactiveEtaCode = true;
        } else if (status == TrainingUtil.ValidationStatus.REVOKED) {
            isEnrollmentCodeRevoked = true;
        }

        Logger.pop();
    }

    /*
        @author         Pranav Raulkar
        @date           26/03/2016
        @description    The method initializes the class variables and performs the enrollment code validation.
    */
    public PageReference checkEnrollmentCode() {
        Logger.push('SelfEnrollmentController', 'checkEnrollmentCode');

        initializeVars();
        fetchEnrollmentCodeRecord();
        setPageLanguage();
        validateEnrollmentCode(eCode);

        Logger.pop();

        return null;
    }

    /*
        @author         Pranav Raulkar
        @date           29/03/2016
        @description    Checks if the enrollment code is valid and prepares the link to 
                        naviagte to when the "Let's get started" button is clicked.
    */
    public PageReference navigateToAuthUrl() {
        PageReference letsGetStarted;
        if(isValidEnrollmentCode) {
            Training_Agreement_Settings__c ENROLL_CODE_CONFIG = Training_Agreement_Settings__c.getOrgDefaults();
            letsGetStarted = new PageReference(String.format(ENROLL_CODE_CONFIG.Self_Enrollment_Authenticated_URL__c, new List<String> { enrollmentCode }));
            letsGetStarted.setRedirect(true);            
        }
        return letsGetStarted;
    }   
}