library TopicRule version '0.1.0'
using FHIR version '4.0.0'
include FHIRHelpers version '4.0.0' called FHIRHelpers

parameter Patient Patient
parameter device_request DeviceRequest

define "Age":
  AgeInYears()

define RULE_APPLIES:
true

define PRIORAUTH_REQUIRED:
true

define DOCUMENTATION_REQUIRED:
  true

define APPROVE_PRIORAUTH:
  "Age" >= 0

define RESULT_InfoLink:
    'https://www.cms.gov/Research-Statistics-Data-and-Systems/Computer-Data-and-Systems/Electronic-Clinical-Templates/Downloads/Respiratory-Assist-Device-Order-Template-Draft-20180412-R10b.pdf'

define RESULT_QuestionnaireOrderUri:
    'Questionnaire/Topic'

define RESULT_QuestionnaireFaceToFaceUri:
  'Questionnaire/TopicFaceToFace'

define RESULT_QuestionnaireLabUri:
    'Questionnaire/TopicLab'

define RESULT_requestId:
  device_request
