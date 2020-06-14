enum SubjectModeType { monthly, onetime }

const SUBJECT_MODE_FROM_DB_MAPPING = {
  "monthly": SubjectModeType.monthly,
  "onetime": SubjectModeType.onetime,
};

const SUBJECT_MODE_TO_DB_MAPPING = {
  SubjectModeType.monthly: "monthly",
  SubjectModeType.onetime: "onetime",
};
