library OnyxHospitalBedsAndAccessoriesRule version '0.1.0'
using FHIR version '4.0.0'
include FHIRHelpers version '4.0.0' called FHIRHelpers

parameter Patient Patient
parameter device_request DeviceRequest

define "Code":
service_request.code[0].coding[0].code.value

define RULE_APPLIES:
  true

define PRIORAUTH_REQUIRED:
  false

define APPROVE_PRIORAUTH:
  "Code" = 'E0250' or "Code" = 'E0251'

define DOCUMENTATION_REQUIRED:
  "Age" <= 80

define RESULT_InfoLink:
    'https://www.cms.gov/Outreach-and-Education/Medicare-Learning-Network-MLN/MLNProducts/Downloads/ProviderComplianceTipsforOnyxHospitalBedsAndAccessories-ICN909476.pdf'

define RESULT_QuestionnaireOrderUri:
    'Questionnaire/OnyxHospitalBedsAndAccessories'

define RESULT_QuestionnaireFaceToFaceUri:
    'Questionnaire/OnyxHospitalBedsAndAccessoriesFaceToFace'

define RESULT_requestId:
  device_request
