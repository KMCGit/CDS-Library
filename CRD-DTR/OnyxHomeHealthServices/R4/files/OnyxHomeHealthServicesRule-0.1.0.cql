library OnyxHomeHealthServicesRule version '0.1.0'
using FHIR version '4.0.0'
include FHIRHelpers version '4.0.0' called FHIRHelpers

parameter Patient Patient
parameter service_request ServiceRequest

define "Age":
  AgeInYears()

define RULE_APPLIES:
  true

define PRIORAUTH_REQUIRED:
  true 

define DOCUMENTATION_REQUIRED:
  true

define APPROVE_PRIORAUTH:
  "Age" >= 70

define RESULT_InfoLink:
  'https://www.cms.gov/Outreach-and-Education/Medicare-Learning-Network-MLN/MLNProducts/Downloads/Medicare-Home-Health-Benefit-Text-Only.pdf'

define RESULT_QuestionnaireOrderUri:
  'Questionnaire/OnyxHomeHealthServices'

define RESULT_QuestionnairePlanOfCareUri:
  'Questionnaire/OnyxHomeHealthServicesPlanOfCare'
  
define RESULT_QuestionnaireFaceToFaceUri:
  'Questionnaire/OnyxHomeHealthServicesFaceToFace'

define RESULT_requestId:
  service_request
