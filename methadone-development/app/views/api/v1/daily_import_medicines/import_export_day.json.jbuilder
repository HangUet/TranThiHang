json.code 1
json.message t("common.success")
json.data @import_exports do |import_export|
  json.production_batch import_export.production_batch
  json.expiration_date import_export.expiration_date.strftime "%d/%m/%Y" rescue nil
  json.import_number import_export.typee == 2 ? import_export.number : nil
  json.export_number import_export.typee == 0 ? import_export.number : nil
  json.sourse import_export.source
end
json.other @other_sources do |other_source|
  json.production_batch other_source.production_batch
  json.expiration_date other_source.expiration_date.strftime "%d/%m/%Y" rescue nil
  json.import_number other_source.typee == 3 ? other_source.number : nil
  json.export_number other_source.typee == 1 ? other_source.number : nil
  json.sourse other_source.source
  json.issuing_name IssuingAgency.where("id = ?",other_source.issuing_agency_id).first.name
end
json.total do
  json.receiver @import_exports.first ? @import_exports.first.receiver : nil
  json.sender @import_exports.first   ? @import_exports.first.sender : nil
  if !@used.nil?
    json.loss @used - @allocation > 0 ? @used - @allocation : nil
    json.redundancy @allocation - @used > 0 ? @allocation - @used : nil
  end
  json.import_total @import.first.sum
  json.export_total @export.first.sum
end
json.total_other do
  json.receiver @other_sources.first  ? @other_sources.first.receiver : nil
  json.sender @other_sources.first    ? @other_sources.first.sender : nil
  json.import_total @import_other.first.sum
  json.export_total @export_other.first.sum
end
