factory_app
.factory("API", ["$http", "$rootScope", "$window", function ($http, $rootScope, $window) {
  return {
    getPatients: function(page, keyword) {
      return $http({
        method: "GET",
        url: "/api/v1/patients",
        params: {
          page: page || 1,
          keyword: keyword
        }
      });
    },
    getPatientsDoctor: function(page, keyword, type) {
      return $http({
        method: "GET",
        url: "/api/v1/doctors/patients",
        params: {
          page: page || 1,
          keyword: keyword,
          type: type
        }
      });
    },
    getDashboardDoctor: function(page, keyword, type) {
      return $http({
        method: "GET",
        url: "/api/v1/doctors/dashboards",
      });
    },
    getPatient: function(id) {
      return $http.get("/api/v1/patients/" + id);
    },
    deletePatient: function(patient_id) {
      return $http.delete("api/v1/patients/" + patient_id);
    },
    getPatientByBarcode: function(barcode) {
      return $http({
        method: "GET",
        url: "/api/v1/patients/get_by_barcode",
        params: {
          barcode: barcode,
        }
      });
    },
    getDosagePatient: function(date, patient_id) {
      return $http({
        method: "GET",
        url: "/api/v1/medicine_allocations/get_dosage_patient",
        params: {
          patient_id: patient_id,
          date: date
        }
      });
    },
    getChangeDosage: function(date) {
      return $http({
        method: "GET",
        url: "api/v1/patients/get_change_dosage",
        params: {
          date: date
        }
      });
    },
    getImportExportDay: function(date) {
      return $http({
        method: "GET",
        url: "/api/v1/daily_import_medicines/import_export_day",
        params: {
          date: date
        }
      });
    },
    getIssuingAgencies: function(page, keyword) {
      return $http({
        method: "GET",
        url: "/api/v1/issuing_agencies",
        params: {
          page: page || 1,
          keyword: keyword
        }
      });
    },
    getIssuingAgenciesOption: function(province_id, district_id, ward_id) {
      return $http({
        method: "GET",
        url: "/api/v1/admin/option_report",
        params: {
          province_id: province_id,
          district_id: district_id,
          ward_id: ward_id
        }
      });
    },
    getIssuingAgenciesByProvince: function(province_id) {
      return $http.get("api/v1/issuing_agencies/get_by_province?province_id=" + province_id);
    },
    getAllIssuingAgencies: function() {
      return $http.get("api/v1/admin/issuing_agencies");
    },
    getAllEmployments: function(page, keyword, keystatus) {
      return $http({
        method: "GET",
        url: "/api/v1/admin/employments",
        params: {
          page: page || 1,
          keyword: keyword,
          keystatus: keystatus
        }
      });
    },
    getEmployment: function(employment_id) {
      return $http.get("api/v1/admin/employments/" + employment_id);
    },
    createEmployment: function(employment) {
      return $http.post("api/v1/admin/employments", {employment: employment});
    },
    updateEmployment: function(employment_id, employment) {
      return $http.put("api/v1/admin/employments/" + employment_id, {employment: employment});
    },
    deleteEmployment: function(employment_id) {
      return $http.delete("api/v1/admin/employments/" + employment_id);
    },
    getAllSources: function(page, keyword, keystatus) {
      return $http({
        method: "GET",
        url: "/api/v1/admin/sources",
        params: {
          page: page || 1,
          keyword: keyword,
          keystatus: keystatus
        }
      });
    },
    getSummaryReportExcel: function(type, date_start, date_end, province_id, district_id,
      ward_id, issuing_agency_id) {
      return $http({
        method: "GET",
        url: "/api/v1/admin/summary_reports.xlsx",
        responseType: 'arraybuffer',
        params: {
          type: type,
          date_start: date_start,
          date_end: date_end,
          province_id: province_id,
          district_id: district_id,
          ward_id: ward_id,
          issuing_agency_id: issuing_agency_id
        }
      });
    },
    getSummaryReport : function(type, date_start, date_end, province_id, district_id,
      ward_id, issuing_agency_id) {
      return $http({
        method: "GET",
        url: "/api/v1/admin/summary_reports",
        params: {
          type: type,
          date_start: date_start,
          date_end: date_end,
          province_id: province_id,
          district_id: district_id,
          ward_id: ward_id,
          issuing_agency_id: issuing_agency_id
        }
      });
    },
    getSource: function(source_id) {
      return $http.get("api/v1/admin/sources/" + source_id);
    },
    createSource: function(source) {
      return $http.post("api/v1/admin/sources", {source: source});
    },
    updateSource: function(source_id, source) {
      return $http.put("api/v1/admin/sources/" + source_id, {source: source});
    },
    deleteSource: function(source_id) {
      return $http.delete("api/v1/admin/sources/" + source_id);
    },
    getAllEducations: function(page, keyword, keystatus) {
      return $http({
        method: "GET",
        url: "/api/v1/admin/educations",
        params: {
          page: page || 1,
          keyword: keyword,
          keystatus: keystatus
        }
      });
    },
    getAllMaritals: function(page, keyword, keystatus) {
      return $http({
        method: "GET",
        url: "/api/v1/admin/maritals",
        params: {
          page: page || 1,
          keystatus: keystatus,
          keyword: keyword
        }
      });
    },
    getEducation: function(education_id) {
      return $http.get("api/v1/admin/educations/" + education_id);
    },
    createEducation: function(education) {
      return $http.post("api/v1/admin/educations", {education: education});
    },
    updateEducation: function(education_id, education) {
      return $http.put("api/v1/admin/educations/" + education_id, {education: education});
    },
    deleteEducation: function(education_id) {
      return $http.delete("api/v1/admin/educations/" + education_id);
    },
    getMarital: function(marital_id) {
      return $http.get("api/v1/admin/maritals/" + marital_id);
    },
    createMarital: function(marital) {
      return $http.post("api/v1/admin/maritals", {marital: marital});
    },
    updateMarital: function(marital_id, marital) {
      return $http.put("api/v1/admin/maritals/" + marital_id, {marital: marital});
    },
    deleteMarital: function(marital_id) {
      return $http.delete("api/v1/admin/maritals/" + marital_id);
    },
    getAllFinancials: function(page, keyword, keystatus) {
      return $http({
        method: "GET",
        url: "/api/v1/admin/financials",
        params: {
          page: page || 1,
          keyword: keyword,
          keystatus: keystatus
        }
      });
    },
    getFinancial: function(financial_id) {
      return $http.get("api/v1/admin/financials/" + financial_id);
    },
    createFinancial: function(financial) {
      return $http.post("api/v1/admin/financials", {financial: financial});
    },
    updateFinancial: function(financial_id, financial) {
      return $http.put("api/v1/admin/financials/" + financial_id, {financial: financial});
    },
    deleteFinancial: function(financial_id) {
      return $http.delete("api/v1/admin/financials/" + financial_id);
    },
    getEthnicities: function() {
      return $http.get("/api/v1/ethnicities");
    },
    getEthnicity: function(ethnicity_id) {
      return $http.get("/api/v1/ethnicities/" + ethnicity_id);
    },
    getWards: function(district_id) {
      return $http.get("/api/v1/wards?district_id=" + district_id);
    },
    getDistricts: function(province_id) {
      return $http.get("/api/v1/districts?province_id=" + province_id);
    },
    getProvinces: function() {
      return $http.get("/api/v1/provinces");
    },
    getMedicineTypes: function() {
      return $http.get("/api/v1/medicine_types");
    },
    updatePatient: function(patient) {
      return $http.put("/api/v1/patients/" + patient.id, {patient: patient});
    },
    createPatient: function(patient, image) {
      return $http.post("/api/v1/patients", {patient: patient});
    },
    getOneIssuingAgency: function(issuing_agency_id) {
      return $http.get("/api/v1/admin/issuing_agencies/" + issuing_agency_id);
    },
    createIssuingAgency: function(issuing_agency) {
      return $http.post("/api/v1/admin/issuing_agencies", {issuing_agency: issuing_agency});
    },
    updateIssuingAgency: function(issuing_agency_id, edit_issuing_agency) {
      return $http.patch("/api/v1/admin/issuing_agencies/" + issuing_agency_id, {issuing_agency: edit_issuing_agency});
    },
    deleteIssuingAgency: function(issuing_agency_id) {
      return $http.delete("/api/v1/admin/issuing_agencies/" + issuing_agency_id);
    },
    getMedicines: function(type, page, keyword) {
      return $http({
        method: "GET",
        url: "/api/v1/medicines",
        params: {
          type: type || 'can_use',
          page: page || 1,
          keyword: keyword
        }
      });
    },
    createMedicine: function(new_medicine) {
      return $http.post("/api/v1/medicines", {medicine: new_medicine});
    },
    getOneMedicine: function(medicine_id) {
      return $http.get("/api/v1/medicines/" + medicine_id);
    },
    updateMedicine:  function(medicine_id, edit_medicine) {
      return $http.patch("/api/v1/medicines/" + medicine_id, {medicine: edit_medicine});
    },
    deleteMedicine: function(medicine_id) {
      return $http.delete("/api/v1/medicines/" + medicine_id);
    },
    getAdministrators: function(page, keyword) {
      return $http({
        method: "GET",
        url: "/api/v1/admin/users",
        params: {
          page: page || 1,
          keyword: keyword
        }
      });
    },
    getMedicinesType: function(type) {
      return $http({
        method: "GET",
        url: "/api/v1/medicines",
        params: {
          type: type
        }
      });
    },
    getAdmin: function(user_id) {
      return $http.get("/api/v1/admin/users/" + user_id);
    },
    createAdmin: function(user) {
      return $http.post("/api/v1/admin/users", {user: user});
    },
    updateAdmin: function(user_id, user) {
      return $http.put("/api/v1/admin/users/" + user_id, {user: user});
    },
    getUsers: function(page, keyword) {
      return $http({
        method: "GET",
        url: "/api/v1/admin_agency/users",
        params: {
          page: page || 1,
          keyword: keyword
        }
      });
    },
    createUser: function(user) {
      return $http.post("/api/v1/admin_agency/users", {user: user});
    },
    getUser: function(user_id) {
      return $http.get("/api/v1/admin_agency/users/" + user_id);
    },
    updateUser: function(user_id, user) {
      return $http.put("api/v1/admin_agency/users/" + user_id, {user: user})
    },
    deleteUser: function(user_id) {
      return $http.delete("/api/v1/admin_agency/users/" + user_id);
    },
    getNotifications: function(page) {
      return $http.get("/api/v1/notifications?page=" + page);
    },
    seeNotification: function(id) {
      return $http.put("/api/v1/notifications/" + id + "/see");
    },
    getPrescription: function(patient_id) {
      return $http.get("/api/v1/prescriptions/" + patient_id);
    },
    createPrescription: function(prescription) {
      return $http.post("/api/v1/prescriptions", {prescription: prescription});
    },
    getListPrescription: function(patient_id) {
      return $http.get("/api/v1/prescriptions?patient_id=" + patient_id);
    },
    getLastPrescriptionOfPatient: function(patient_id) {
      return $http.get("/api/v1/prescriptions/get_last_prescription_of_patient?patient_id=" + patient_id);
    },
    updatePrescription: function(prescription_id, prescription) {
      return $http.patch("/api/v1/prescriptions/" + prescription_id, {prescription: prescription});
    },
    deletePrescription: function(prescription_id) {
      return $http.delete("/api/v1/prescriptions/" + prescription_id);
    },
    closePrescription: function(prescription_id) {
      return $http.get("/api/v1/close_prescription/" + prescription_id);
    },
    getOnePrescription: function(prescription_id) {
      return $http.get("/api/v1/get_prescription/" + prescription_id);
    },
    getTreatmentHistory: function(patient_id) {
      return $http.get("api/v1/treatment_histories/" + patient_id);
    },
    createTreatment: function(data, note, patient_id) {
      return $http.patch("api/v1/treatment_histories/" + patient_id, {treatment_history: data, note: note})
    },
    getMedicineAllocation: function(patient_id) {
      return $http({
        method: "GET",
        url: "api/v1/medicine_allocations",
        params: {
          patient_id: patient_id
        }
      });
    },
    getAllPatientsByAllocation: function(page) {
      return $http({
        method: "GET",
        url: "/api/v1/medicine_allocations/get_by_patient",
        params: {
          page: page || 1
        }
      });
    },
    getMedicineAllocationById: function (id) {
      return $http({
        method: "GET",
        url: "/api/v1/medicine_allocations/get_by_id",
        params: {
          id: id,
        }
      });
    },
    getHistoryMedicationAllocation: function(patient_id, from_date, to_date) {
      return $http({
        method: "GET",
        url: "/api/v1/medicine_allocations",
        params: {
          patient_id: patient_id,
          from_date: from_date,
          to_date: to_date
        }
      });
    },

    export_bill: function(patient_id, month, year) {
      // return $http.get("api/v1/medicine_allocations/export");
      return $http({
        method: "GET",
        url: "/api/v1/exports.xlsx",
        responseType: 'arraybuffer',
        params: {
          patient_id: patient_id,
          month: month,
          year: year
        }
      });
    },
    printPrescription: function(prescription_id) {
      return $http({
        method: "GET",
        url: "/api/v1/prints",
        params: {
          id: prescription_id
        }
      });
    },
    sendMedicineNotify: function(notification, medicine_allocation_id, type) {
      return $http.post("/api/v1/notifications", {
        notification: notification,
        medicine_allocation_id: medicine_allocation_id,
        type: type
      });
    },
    getNotifyFalledMedicine: function(id) {
      return $http.get("api/v1/notifications/" + id);
    },
    getPatientAgencyHistory: function(id) {
      return $http.get("api/v1/notifications/" + id);
    },
    agreeAllocation: function(medicine_allocation_id, status, notify_status) {
      return $http.patch("/api/v1/medicine_allocations/" + medicine_allocation_id, { status: status, notify_status: notify_status });
    },
    agreePrescription: function(prescription, status, notify_status
      , medicine_allocation_id, prescription_id, vomited_time) {
      return $http.post("/api/v1/prescriptions", {
        prescription: prescription,
        status: status,
        notify_status: notify_status,
        medicine_allocation_id: medicine_allocation_id,
        prescription_id: prescription_id,
        vomited_time: vomited_time
      });
    },
    createMedicineAllocation: function(patient_id, allocation, medicine_allocation_id, drinked_day_medicine_id) {
      return $http.post("api/v1/medicine_allocations", {
        patient_id: patient_id,
        allocation: allocation,
        medicine_allocation_id: medicine_allocation_id,
        drinked_day_medicine_id: drinked_day_medicine_id
      });
    },
    backMedicineAllocation: function(patient_id, allocation, medicine_allocation_id, back, drinked_day_medicine_id) {
      return $http.post("api/v1/medicine_allocations", {
        patient_id: patient_id,
        allocation: allocation,
        medicine_allocation_id: medicine_allocation_id,
        back: back,
        drinked_day_medicine_id: drinked_day_medicine_id
      });
    },
    createPatientAgencyHistory: function(patient_agency_history) {
      return $http.post("api/v1/patient_agency_histories", {
        patient_agency_history: patient_agency_history
      });
    },
    getAllPatientAgencyHistory: function(patient_id) {
       return $http({
        method: "GET",
        url: "/api/v1/patient_agency_histories",
        params: {
          patient_id: patient_id,
        }
      });
    },
    getPatientAgencyHistory: function(id) {
      return $http.get("api/v1/patient_agency_histories/" + id);
    },
    feedbackPatientAgencyHistory: function(id, status) {
      return $http.put("api/v1/patient_agency_histories/" + id + "/feedback", {
        status: status
      });
    },
    feedbackSamePatient: function(sender_agency_id, id, status) {
      return $http.put("api/v1/same_patients/" + id + "/feedback", {
        status: status,
        sender_agency_id: sender_agency_id
      });
    },
    deletePatientAgencyHistory: function(patient_id) {
      return $http.delete("api/v1/patient_agency_histories/" + patient_id)
    },
    getListPatientWarnings: function(page, keyword) {
      return $http({
        method: "GET",
        url: "/api/v1/patient_warnings",
        params: {
          page: page || 1,
          keyword: keyword
        }
      });
    },
    getPatientWarnings: function(patient_id) {
      return $http.get("api/v1/patient_warnings/" + patient_id);
    },
    updatePatientWarnings: function(patient_id) {
      return $http.put("/api/v1/patient_warnings/" + patient_id);
    },
    getPatientReport: function(month) {
      return $http({
        method: "GET",
        url: "/api/v1/medicine_allocations/get_patient_report",
        params: {
          month: month
        }
      })
    },
    getDailyImport: function() {
      return $http.get("/api/v1/daily_import_medicines");
    },
    createImportMedicine: function(medicine) {
      return $http.post("/api/v1/daily_import_medicines", {vouchers: medicine})
    },
    getImportMedicine: function(medicine_id) {
      return $http.get("/api/v1/daily_import_medicines/" + medicine_id);
    },
    updateImportMedicine: function(medicine_id, importMedicine) {
      return $http.put("/api/v1/daily_import_medicines/" + medicine_id, {vouchers: importMedicine})
    },
    deleteImportMedicine: function(medicine_id) {
      return $http.delete("/api/v1/daily_import_medicines/" + medicine_id);
    },
    getDailyExport: function() {
      return $http.get("/api/v1/daily_export_medicines");
    },
    createExportMedicine: function(medicine) {
      return $http.post("/api/v1/daily_export_medicines", {vouchers: medicine})
    },
    getExportMedicine: function(medicine_id) {
      return $http.get("/api/v1/daily_export_medicines/" + medicine_id);
    },
    updateExportMedicine: function(medicine_id, medicine) {
      return $http.put("/api/v1/daily_export_medicines/" + medicine_id, {vouchers: medicine});
    },
    deleteExportportMedicine: function(medicine_id) {
      return $http.delete("/api/v1/daily_export_medicines/" + medicine_id);
    },
    voucherMedicine: function() {
      return $http({
        method: "GET",
        url: "/api/v1/vouchers",
        params: {
          type: 1,
        }
      });
    },
    createVoucher: function (voucher) {
      return $http.post("/api/v1/vouchers", {voucher: voucher});
    },
    getVoucher: function (voucher_id) {
      return $http.get("/api/v1/vouchers/" + voucher_id);
    },
    updateVoucher: function (voucher_id, voucher) {
      return $http.put("/api/v1/vouchers/" + voucher_id, {voucher: voucher});
    },
    acceptVoucher: function (voucher_id) {
      return $http.put("/api/v1/vouchers/" + voucher_id, {type: "accept"})
    },
    deleteVoucher: function (voucher_id) {
      return $http.delete("/api/v1/vouchers/" + voucher_id);
    },
    medicineDelivery: function(id) {
      return $http({
        method: "GET",
        url: "/api/v1/medicine_deliveries",
        params: {
          voucher_id: id
        }
      });
    },
    getMedicineDeliveries: function(id) {
      return $http.get("/api/v1/medicine_deliveries/" + id);
    },
    updateMedicineDeliveries: function(id, medicine, old_number) {
      return $http.put("/api/v1/medicine_deliveries/" + id, {medicines: medicine, old_number: old_number});
    },
    deleteMedicineDeliveries: function(id) {
      return $http.delete("/api/v1/medicine_deliveries/" + id);
    },
    medicineReceived: function(id) {
      return $http({
        method: "GET",
        url: "/api/v1/medicine_received",
        params: {
          voucher_id: id
        }
      });
    },
    updateMedicineReceived: function(id, medicine) {
      return $http.put("/api/v1/medicine_received/" + id, {medicines: medicine});
    },
    deleteMedicineReceived: function(id) {
      return $http.delete("/api/v1/medicine_received/" + id);
    },
    getMedicineReceived: function(id) {
      return $http.get("/api/v1/medicine_received/" + id);
    },
    createMedicineImport: function(medicine) {
      return $http.post("/api/v1/medicine_deliveries", {medicines: medicine});
    },
    createMedicineExport: function(medicine) {
      return $http.post("/api/v1/medicine_received", {medicines: medicine});
    },
    // thay bang Medicine
    getAllMedicine: function(type) {
      return $http({
        method: "GET",
        url: "/api/v1/medicines",
        params: {
          type: type
        }
      });
    },
    getImportExportMedicineDay: function(day) {
      return $http({
        method: "GET",
        url: "/api/v1/import_export_medicines",
        params: {
          day: day
        }
      });
    },
    getStoreReport: function(month) {
      return $http({
        method: "GET",
        url: "api/v1/daily_import_medicines/get_store_report",
        params: {
          month: month
        }
      });
    },
    getNurseVouchers: function() {
      return $http.get("/api/v1/nurses/vouchers");
    },
    getNurseMedicineVouchers: function() {
      return $http.get("/api/v1/nurses/medicine_deliveries");
    },
    getNurseVouchersImport: function() {
      return $http.get("/api/v1/nurses/vouchers?type=import");
    },
    getNurseMedicineVouchersImport: function() {
      return $http.get("/api/v1/nurses/medicine_received");
    },
    AcceptVoucher: function(voucher_id) {
      return $http.put("/api/v1/nurses/vouchers/" + voucher_id);
    },
    AcceptVoucherImport: function(voucher_medicines) {
      return $http.post("/api/v1/nurses/medicine_received", {voucher_medicines: voucher_medicines});
    },
    sendStopTreatment: function(stop_treatment) {
      return $http.post("/api/v1/stop_treatment_histories", {stop_treatment: stop_treatment});
    },
    ContinueTreatment: function(patient_id) {
      return $http.post("/api/v1/stop_treatment_histories", {patient_id: patient_id});
    },
    getListMedicines: function() {
      return $http.get("/api/v1/list_medicines");
    },
    updateName: function(user) {
      return $http.put("/api/v1/users/update_name", {user: user});
    },
    advanceSearch: function(patient, page) {
      return $http.post("/api/v1/doctors/search_patient", {patient: patient, page: page || 1});
    },
    searchAndExport: function(patient) {
      return $http({
        method: "POST",
        url: "/api/v1/doctors/search_and_export.xlsx",
        responseType: 'arraybuffer',
        data: {patient: patient}
      });
    },
    advanceNurseSearch: function(patient, page) {
      return $http.post("/api/v1/search_by_nurse", {patient: patient, page: page || 1});
    },
    searchAndNurseExport: function(patient) {
      return $http({
        method: "POST",
        url: "/api/v1/search_and_export_by_nurse.xlsx",
        responseType: 'arraybuffer',
        data: {patient: patient}
      });
    },
    filterPrescription: function(patient_id, begin_date_from,
      begin_date_to, end_date_from, end_date_to, doctor_id) {
      return $http({
        method: "GET",
        url: "/api/v1/filter_prescription",
        params: {
          patient_id: patient_id,
          begin_date_from: begin_date_from,
          begin_date_to: begin_date_to,
          end_date_from: end_date_from,
          end_date_to: end_date_to,
          doctor_id: doctor_id
        }
      });
    },
    listPrescriptionCreator: function() {
      return $http({
        method: "GET",
        url: "/api/v1/users/get_prescription_creator",
      });
    },
    getListMedicines: function(page, keyword, keystatus) {
      return $http({
        method: "GET",
        url: "/api/v1/list_medicines",
        params: {
          page: page,
          keyword: keyword,
          keystatus: keystatus
        }
      });
    },
    createMedicineList: function(medicine_list) {
      return $http.post("/api/v1/list_medicines", {medicine_list: medicine_list});
    },
    getAMedicineList: function(medicine_list_id) {
      return $http.get("/api/v1/list_medicines/" + medicine_list_id);
    },
    updateMedicineList: function(medicine_list_id, medicine_list, confirm_deactived) {
      return $http.put("/api/v1/list_medicines/" + medicine_list_id, {medicine_list: medicine_list, confirm_deactived: confirm_deactived});
    },
    deleteMedicineList: function(medicine_list_id, deactived) {
      return $http({
        method: "DELETE",
        url: "/api/v1/list_medicines/" + medicine_list_id,
        params: {
          deactived: deactived
        }
      });
    },
    getProviders: function(page, keyword, keystatus) {
      return $http({
        method: "GET",
        url: "/api/v1/admin/providers",
        params: {
          page: page || 1,
          keyword: keyword,
          keystatus: keystatus
        }
      });
    },
    getAllProviders: function(page, keyword) {
      return $http.get("/api/v1/admin/get_all_providers");
    },
    updateProvider: function(provider_id, provider) {
      return $http.put("/api/v1/admin/providers/" + provider_id, {provider: provider});
    },
    getProvider: function(provider_id) {
      return $http.get("/api/v1/admin/providers/" + provider_id);
    },
    deleteProvider: function(provider_id, deactived) {
      return $http({
        method: "DELETE",
        url: "/api/v1/admin/providers/" + provider_id,
        params: {
          deactived: deactived
        }
      });
    },
    createProvider: function(provider) {
      return $http.post("/api/v1/admin/providers/", {provider: provider});
    },
    getManufacturers: function(page, keyword, keystatus) {
      return $http({
        method: "GET",
        url: "/api/v1/admin/manufacturers",
        params: {
          page: page || 1,
          keyword: keyword,
          keystatus: keystatus
        }
      });
    },
    getReasons: function(page, keyword, keystatus) {
      return $http({
        method: "GET",
        url: "/api/v1/admin/stop_reasons",
        params: {
          page: page || 1,
          keyword: keyword,
          keystatus: keystatus
        }
      });
    },
    getAllManufacturers: function(page, keyword) {
      return $http.get("/api/v1/admin/get_all_manufacturers");
    },
    createManufacturer: function(manufacturer) {
      return $http.post("/api/v1/admin/manufacturers/", {manufacturer: manufacturer});
    },
    getAManufacturer: function(manufacturer_id) {
      return $http.get("/api/v1/admin/manufacturers/" + manufacturer_id);
    },
    deleteManufacturer: function(manufacturer_id, deactived) {
      return $http({
        method: "DELETE",
        url: "/api/v1/admin/manufacturers/" + manufacturer_id,
        params: {
          deactived: deactived
        }
      });
    },
    updateManufacturer: function(manufacturer_id, manufacturer) {
      return $http.put("/api/v1/admin/manufacturers/" + manufacturer_id, {manufacturer: manufacturer});
    },
    sendSamePatient: function(current_agency_id, receive_agency_id, patient_id) {
      return $http({
        method: "POST",
        url: "/api/v1/same_patients",
        params: {
          current_agency_id: current_agency_id,
          receive_agency_id: receive_agency_id,
          patient_id: patient_id
        }
      });
    },
    getAllReasons: function() {
      return $http.get("/api/v1/admin/get_all_stop_reasons");
    },
    getReason: function(reason_id, reason) {
      return $http.get("/api/v1/admin/stop_reasons/" + reason_id);
    },
    updateReason: function(reason_id, reason) {
      return $http.put("/api/v1/admin/stop_reasons/" + reason_id, {reason: reason});
    },
    deleteReason: function(reason_id) {
      return $http.delete("/api/v1/admin/stop_reasons/" + reason_id);
    },
    createReason: function(reason) {
      return $http.post("/api/v1/admin/stop_reasons/", {reason: reason});
    },
    getHistoryFalled: function(card_number, name, creator, from_date, to_date, status, page) {
      return $http({
        method: "GET",
        url: "/api/v1/get_falled_history",
        params: {
          card_number: card_number,
          name: name,
          creator: creator,
          from_date: from_date,
          to_date: to_date,
          status: status,
          page: page
        }
      });
    },
    listNurse: function() {
      return $http({
        method: "GET",
        url: "/api/v1/users/get_nurse",
      });
    },
    deleteReport: function(id) {
      return $http.delete("/api/v1/medicine_allocations/" + id);
    },
    getAdminAgency: function() {
      return $http.get("/api/v1/users/get_admin_agency");
    },
    getExecutiveStaff: function() {
      return $http.get("/api/v1/users/get_executive_staff");
    },
    getListDoctor: function() {
      return $http.get("/api/v1/users/get_list_doctor");
    },
    searchCardStore: function(from_date, to_date, medicine_list_id) {
      return $http({
        method: "GET",
        url: "/api/v1/nurses/nurse_card_stores/",
        params: {
          from_date: from_date,
          to_date: to_date,
          medicine_list_id: medicine_list_id
        }
      });
    },
    searchCardStoreMain: function(from_date, to_date, medicine_list_id) {
      return $http({
        method: "GET",
        url: "/api/v1/card_stores/",
        params: {
          from_date: from_date,
          to_date: to_date,
          medicine_list_id: medicine_list_id
        }
      });
    },
    searchSituationUseMain: function(from_date, to_date, medicine_name) {
      return $http({
        method: "GET",
        url: "/api/v1/situation_uses/",
        params: {
          from_date: from_date,
          to_date: to_date,
          medicine_name: medicine_name
        }
      });
    },
    checkVommited: function(patient_id) {
      return $http.post("/api/v1/check_vomited", {patient_id: patient_id});
    },
    getAllUsers: function() {
      return $http.get("/api/v1/users/get_all_users");
    },
    getReportCreateor: function(type, init_date) {
      return $http({
        method: "GET",
        url: "/api/v1/all_report_creator",
        params: {
          type: type,
          init_date: init_date
        }
      });
    },
    createReport: function(list_user, type) {
      return $http.post("/api/v1/reports", {list_user: list_user, type: type});
    },
    getLostMedicine: function(day) {
      return $http.post("/api/v1/get_lost_medicine", {day: day});
    },
    searchReport: function(from_date, to_date, type) {
      return $http.post("/api/v1/search_report", {from_date: from_date, to_date: to_date, type: type});
    },
    getListPatientRevoke: function(card_number, name, from_date, to_date, page) {
      return $http({
        method: "GET",
        url: "/api/v1/get_list_patient_revoke",
        params: {
          card_number: card_number,
          name: name,
          from_date: from_date,
          to_date: to_date,
          page: page
        }
      });
    },
    getTimeDropMedicine: function(patient_id) {
      return $http({
        method: "GET",
        url: "/api/v1/get_time_drop_medicine",
        params: {
          patient_id
        }
      });
    },
    getLossReduncy: function(time_type, time, type) {
      return $http({
        method: "GET",
        url: "/api/v1/get_loss_reduncy",
        params: {
          time_type: time_type,
          time: time,
          type: type
        }
      });
    }
  }
}])
