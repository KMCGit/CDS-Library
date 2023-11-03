library NuclearStressTestPrepopulation version '0.1.0'

using FHIR version '4.0.0'

include FHIRHelpers version '4.0.0' called FHIRHelpers
include CDS_Connect_Commons_for_FHIRv400 version '1.0.2' called CDS
include DTRHelpers version '0.1.0' called DTR

codesystem "ICD-10-CM": 'http://hl7.org/fhir/sid/icd-10-cm'
codesystem "LOINC": 'http://loinc.org'
codesystem "SNOMED-CT": 'http://snomed.info/sct'
codesystem "HCPCS": 'https://bluebutton.cms.gov/resources/codesystem/hcpcs'

valueset "Asthma": 'com:motivemi:valueset:mmi-36522'
valueset "Hypertension": 'com:motivemi:valueset:mmi-33281'
valueset "COPD": 'com:motivemi:valueset:mmi-36496'
valueset "LDL Cholesterol": 'com:motivemi:valueset:mmi-38467'
valueset "Diastolic BP": 'com:motivemi:valueset:mmi-34850'
valueset "Nuclear Stress Testing CPT": 'com:motivemi:valueset:mmi-36737'
valueset "Gender": 'com:motivemi:valueset:mmi-33104'
valueset "Outpatient Office Visit": 'com:motivemi:valueset:mmi-32838'
valueset "HDL Cholesterol": 'com:motivemi:valueset:mmi-38466'
valueset "2nd or 3rd Degree AV Block": 'com:motivemi:valueset:mmi-38182'
valueset "Total Cholesterol": 'com:motivemi:valueset:mmi-38468'
valueset "Acute Coronary Syndrome": 'com:motivemi:valueset:mmi-36609'
valueset "Antihypertensive Medications": 'com:motivemi:valueset:mmi-38465'
valueset "Type 2 Diabetes": 'com:motivemi:valueset:mmi-36620'
valueset "ASCVD": 'com:motivemi:valueset:mmi-36674'
valueset "Ventricular Tachycardia": 'com:motivemi:valueset:mmi-38469'
valueset "Smoking Status": 'com:motivemi:valueset:mmi-34421'
valueset "Systolic BP": 'com:motivemi:valueset:mmi-34911'

context Patient

define function CreateDisplayInfo(code String, date String) returns String:
  code & if date is null then '' 
    else ' (' & date & ')'

//Section 1: Retrive Patient Information

//What is this member's ID?
define "memberID":
  Patient.id.value

//What is this member's first name?
define "memberFirstName":
  Patient.name[0].given[0].value

//What is this member's middle initial?
define "memberMiddleInitial":
  Patient.name[0].given[1].value

//What is this member's last name?
define "memberLastName":
  Patient.name[0].family.value

//What is this member's gender?
define "memberGender":
  Patient.gender.value

//What is this member's birthdate?
define "memberBirthDate":
  Patient.birthDate.value

//What is this member's age?
define "memberAgeInYears":
  AgeInYears()

//What is this member's home address?
define "memberAddress":
  Patient.address[0].text.value

// Section 2: Retrive Provider Information

//What is the ID of the practitioner evaluating the member?
define "memberPractitionerID":
  First([Practitioner] P
      return P.id.value
  )

//What is the requesting practitioner's first name?
define "practitionerFirstName":
  First([Practitioner] P
      return P.name[0].given[0].value
  )

//What is the requesting practitioner's last name?
define "practitionerLastName":
  First([Practitioner] P
      return P.name[0].family.value
  )

//What is the requesting practitioner's prefix?
define "practitionerPrefix":
  First([Practitioner] P
      return P.name[0].prefix[0].value
  )

define "dateOfFaceToFaceVisit":
  First([Procedure] Proc
      where Proc.code in "Outpatient Office Visit"
      return Proc.performed.start.value
  )

// Section 3: Data required to calculate ASCVD score

//Is this member a current user of tobacco?
define "memberSmokingStatus":
  First([Observation] O
      where O.code in "Smoking Status"
      return Tuple {
        StatusAsOfDate: date from O.effective,
        Status: FHIRHelpers.ToString(O.code.coding[0]."display")
      }
  )

define "memberSmokingStatusCode":
  "memberSmokingStatus".Status

define "memberSmokingStatusDate":
  "memberSmokingStatus".StatusAsOfDate

//Is the member diabetic?
define "memberDiabetesInfo":
  First([Condition] C
      where C.code in "Type 2 Diabetes"
      return Tuple {
        onset: date from C.onset,
        DxCode: FHIRHelpers.ToString(C.code.coding[0].code)
      }
  )

define "memberIsDiabetic":
  "memberDiabetesInfo" is not null

//Has member been diagnosed as having high blood pressure?
define "memberHypertensionInfo":
  First([Condition] C
      where C.code in "Hypertension"
      return Tuple {
        onset: date from C.onset,
        DxCode: FHIRHelpers.ToString(C.code.coding[0].code)
      }
  )

define "memberHasHypertension":
  "memberHypertensionInfo" is not null

//What is the list of this member's medical conditions, with dates of onset?
define "memberDiagnosisListWithOnsetDate":
  [Condition] C
    return Tuple {
      Problem: FHIRHelpers.ToString ( C.code.coding[0]."display" ),
      DxCode: FHIRHelpers.ToString ( C.code.coding[0].code ),
      OnsetDate: date from C.onset
    }

//What medications does the member take?
define "memberMedicationList":
  [MedicationDispense] M
    return FHIRHelpers.ToString ( (M.medication as CodeableConcept).coding[0]."display" ) & ' (' & FHIRHelpers.ToString ( (M.medication as CodeableConcept).coding[0].code ) & ')'

//What antihypertensives does this member take?
define "membersAntihypertensiveMedicationInfo":
  First([MedicationDispense] M
      where (M.medication as CodeableConcept) in "Antihypertensive Medications"
      return Tuple {
        Medication: FHIRHelpers.ToString((M.medication as CodeableConcept).coding[0]."display"),
        RxCode: FHIRHelpers.ToString((M.medication as CodeableConcept).coding[0].code)
      }
  )

define "membersAntihypertensiveMedication":
  "membersAntihypertensiveMedicationInfo".Medication

define "membersAntihypertensiveCode":
  "membersAntihypertensiveMedicationInfo".RxCode

//What is this member's systolic blood pressure?
define "memberSystolicBloodPressure":
  First([Observation] O
      where O.code in "Systolic BP"
      return FHIRHelpers.ToDecimal(O.value.value)
  )

//What is this member's systolic blood pressure?
define "memberDiastolicBloodPressure":
  First([Observation] O
      where O.code in "Diastolic BP"
      return FHIRHelpers.ToDecimal(O.value.value)
  )

//What is this member's total cholesterol level?
define "memberTotalCholesterol":
  First([Observation] O
      where O.code in "Total Cholesterol"
      return FHIRHelpers.ToDecimal(O.value.value)
  )

//What is this member's LDL cholesterol level?
define "memberLDLCholesterol":
  First([Observation] O
      where O.code in "LDL Cholesterol"
      return FHIRHelpers.ToDecimal(O.value.value)
  )

//What is this member's HDL cholesterol level?
define "memberHDLCholesterol":
  First([Observation] O
      where O.code in "HDL Cholesterol"
      return FHIRHelpers.ToDecimal(O.value.value)
  )

// Section 4: Nuclear stress test contraindications

// 48 hour lookaround
define "48HrLookUpTimeframeStart":
  Today() - 2 'days'

define "48HrLookUpTimeframeEnd":
  Today()

define "48HrLookUpTimeframe":
  Interval["48HrLookUpTimeframeStart", "48HrLookUpTimeframeEnd"]

//Has this member had asthma?
define "memberAsthmaInfo":
  First([Condition] C
      where C.code in "Asthma"
      return CreateDisplayInfo(FHIRHelpers.ToString(C.code.coding[0].code), FHIRHelpers.ToString(C.onset))
  )

//Has this member had COPD?
define "memberCOPDInfo":
  First([Condition] C
      where C.code in "COPD"
      return CreateDisplayInfo(FHIRHelpers.ToString(C.code.coding[0].code), FHIRHelpers.ToString(C.onset))
  )

//Has this member had acute coronary syndrome?
define "memberAcuteCoronarySyndromeInLast48Hours":
  First([Condition] C
      where C.code in "Acute Coronary Syndrome"
        and date from C.onset in day of "48HrLookUpTimeframe"
      return CreateDisplayInfo(FHIRHelpers.ToString(C.code.coding[0].code), FHIRHelpers.ToString(C.onset))
  )

define "memberHadAcuteCoronarySyndromeInLast48Hours":
  exists "memberAcuteCoronarySyndromeInLast48Hours"

//Has this member had ventricular tachycardia in the last 48 hours?
define "memberVentricularTachycardiaInLast48Hours":
  First([Condition] C
      where C.code in "Ventricular Tachycardia"
        and date from C.onset in day of "48HrLookUpTimeframe"
      return CreateDisplayInfo(FHIRHelpers.ToString(C.code.coding[0].code), FHIRHelpers.ToString(C.onset))
  )

define "memberHadVentricularTachycardiaInLast48Hours":
  "memberVentricularTachycardiaInLast48Hours" is not null

//Does this member have 2nd or 3rd degree AV block?
define "memberSecondOrThirdDegreeHeartBlock":
  First([Condition] C
      where C.code in "2nd or 3rd Degree AV Block"
      return CreateDisplayInfo(FHIRHelpers.ToString(C.code.coding[0].code), FHIRHelpers.ToString(C.onset))
  )

define "memberHadSecondOrThirdDegreeHeartBlock":
  "memberSecondOrThirdDegreeHeartBlock" is not null