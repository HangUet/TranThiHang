json.code 1
json.message t("common.success")
json.data @notifications
json.total_unseen @total_unseen
json.total @notifications.total_entries
json.page params[:page].to_i || 1
