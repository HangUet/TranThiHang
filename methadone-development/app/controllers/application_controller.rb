class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception,
    if: Proc.new {|c| c.request.format != "application/json"}
  protect_from_forgery with: :null_session,
    if: Proc.new {|c| c.request.format == "application/json"}

  require "jsonwebtoken"
  respond_to :json, if: Proc.new {|c| c.request.format == "application/json"}

  def authenticate_request!
    token = request.headers['Authorization'].split(' ').last rescue nil
    payload = token.nil? ? nil : JsonWebToken.decode(token) rescue nil
    if payload.nil? || !JsonWebToken.valid_payload(payload.first)
      render json: {code: 0,
        message: "Bạn cần phải đăng nhập trước khi tiếp tục."}, status: 401
      return
    end
    @current_user = User.find_by_id payload.first['user_id']
  end

  def load_user_authentication
    @user = User.find_by email: user_params[:email]
    if !@user || !@user.active_for_authentication?
      render json: {code: 0,
        message: t("devise.failure.not_found_in_database")}, status: 200
    else
      if @user.locked_at.nil?
        unless @user.valid_password?(user_params[:password])
          @user.update_columns(failed_attempts: @user.failed_attempts + 1)
          if @user.failed_attempts == Settings.max_failed_attempts - 1
            render json: {code: 0,
              message: "Bạn có thêm 1 lần thử trước khi bị khóa tài khoản"}, status: 200
          elsif @user.failed_attempts >= Settings.max_failed_attempts
            @user.lock_access!
            render json: {code: 0, message: "Tài khoản của bạn đã bị khóa. Truy cập email để được hướng dẫn mở khóa tài khoản"}
          else
            render json: {code: 0,
              message: t("devise.failure.not_found_in_database")}, status: 200
          end
        else
          @user.update_columns(failed_attempts: 0)
        end
      else
        render json: {code: 3, message: "Tài khoản của bạn đã bị khóa"}
      end
    end
  end

  def update_inventory typee, datee, issuing_agency_id, number, medicine_id
    inventory = Inventory.where(issuing_agency_id: issuing_agency_id,
                               datee: datee, medicine_id: medicine_id).first
    if typee == "import"
      if inventory.present?
        inventory.update_attributes import: (inventory.import + number),
                                    endd: inventory.endd + number
      else
        last_inventory = Inventory.where(issuing_agency_id: issuing_agency_id)
                                  .where("datee < ?", datee)
                                  .where(medicine_id: medicine_id)
                                  .order(datee: :desc).first
        if last_inventory.present?
          last_inventory_end_day = last_inventory.endd
        else
          last_inventory_end_day = 0
        end
        Inventory.create issuing_agency_id: issuing_agency_id,
                         datee: datee,
                         beginn: last_inventory_end_day,
                         import: number,
                         medicine_id: medicine_id,
                         endd: last_inventory_end_day + number
      end
      inventories = Inventory.where(issuing_agency_id: issuing_agency_id)
                             .where(medicine_id: medicine_id)
                             .where("datee > ?", datee)
      if inventories.length > 0
        inventories.each do |inventory|
          inventory.update_attributes beginn: inventory.beginn + number,
                                      endd: inventory.endd + number
        end
      end
    elsif typee == "export"
      if inventory.present?
        inventory.update_attributes export: (inventory.export + number),
                                    endd: (inventory.endd - number)
      else
        last_inventory = Inventory.where(issuing_agency_id: issuing_agency_id)
                                  .where("datee < ?", datee)
                                  .where(medicine_id: medicine_id)
                                  .order(datee: :desc).first
        if last_inventory.present?
          last_inventory_end_day = last_inventory.endd
        else
          last_inventory_end_day = 0
        end
        Inventory.create issuing_agency_id: issuing_agency_id,
                         datee: datee,
                         beginn: last_inventory_end_day,
                         export: number,
                         medicine_id: medicine_id,
                         endd: last_inventory_end_day - number
      end
      inventories = Inventory.where(issuing_agency_id: issuing_agency_id)
                             .where(medicine_id: medicine_id)
                             .where("datee > ?", datee)
      if inventories.length > 0
        inventories.each do |inventory|
          inventory.update_attributes beginn: inventory.beginn - number,
                                      endd: inventory.endd - number
        end
      end
    elsif typee == "export_allocate"
      if inventory.present?

        inventory.update_attributes export_allocate: inventory.export_allocate + number,
                                    endd: inventory.endd - number
      else
        last_inventory = Inventory.where(issuing_agency_id: issuing_agency_id)
                                  .where("datee < ?", datee)
                                  .where(medicine_id: medicine_id)
                                  .order(datee: :desc).first
        if last_inventory.present?
          last_inventory_end_day = last_inventory.endd
        else
          last_inventory_end_day = 0
        end
        Inventory.create issuing_agency_id: issuing_agency_id,
                         datee: datee,
                         beginn: last_inventory_end_day,
                         export_allocate: number,
                         medicine_id: medicine_id,
                         endd: last_inventory_end_day - number
      end
      inventories = Inventory.where(issuing_agency_id: issuing_agency_id)
                             .where(medicine_id: medicine_id)
                             .where("datee > ?", datee)
      if inventories.length > 0
        inventories.each do |inventory|
          inventory.update_attributes beginn: inventory.beginn - number,
                                      endd: inventory.endd - number
        end
      end
    elsif typee == "import_end_day"
      if inventory.present?

        inventory.update_attributes import_end_day: inventory.import_end_day + number,
                                    endd: inventory.endd + number
      else
        last_inventory = Inventory.where(issuing_agency_id: issuing_agency_id)
                                  .where("datee < ?", datee)
                                  .where(medicine_id: medicine_id)
                                  .order(datee: :desc).first
        if last_inventory.present?
          last_inventory_end_day = last_inventory.endd
        else
          last_inventory_end_day = 0
        end
        Inventory.create issuing_agency_id: issuing_agency_id,
                         datee: datee,
                         beginn: last_inventory_end_day,
                         medicine_id: medicine_id,
                         endd: last_inventory_end_day + number,
                         import_end_day: number
      end
      inventories = Inventory.where(issuing_agency_id: issuing_agency_id)
                             .where(medicine_id: medicine_id)
                             .where("datee > ?", datee)
      if inventories.length > 0
        inventories.each do |inventory|
          inventory.update_attributes beginn: inventory.beginn + number,
                                      endd: inventory.endd + number
        end
      end
    elsif typee == "falled" && medicine_id.present?
      if inventory.present?

        inventory.update_attributes falled: inventory.falled + number
      else
        last_inventory = Inventory.where(issuing_agency_id: issuing_agency_id)
                                  .where("datee < ?", datee)
                                  .where(medicine_id: medicine_id)
                                  .order(datee: :desc).first
        if last_inventory.present?
          last_inventory_end_day = last_inventory.endd
        else
          last_inventory_end_day = 0
        end
        Inventory.create issuing_agency_id: issuing_agency_id,
                         datee: datee,
                         beginn: last_inventory_end_day,
                         falled: number,
                         medicine_id: medicine_id,
                         endd: last_inventory_end_day
      end
    elsif typee == "not_fall" && medicine_id.present?
      if inventory.present?

        inventory.update_attributes falled: inventory.falled - number
      else
        last_inventory = Inventory.where(issuing_agency_id: issuing_agency_id)
                                  .where("datee < ?", datee)
                                  .where(medicine_id: medicine_id)
                                  .order(datee: :desc).first
        if last_inventory.present?
          last_inventory_end_day = last_inventory.endd
        else
          last_inventory_end_day = 0
        end
        Inventory.create issuing_agency_id: issuing_agency_id,
                         datee: datee,
                         beginn: last_inventory_end_day,
                         falled: -number,
                         medicine_id: medicine_id,
                         endd: last_inventory_end_day
      end
    end
  end

  def update_sub_inventory typee, datee, issuing_agency_id, number, medicine_id
    inventory = SubInventory.where(issuing_agency_id: issuing_agency_id,
                               datee: datee, medicine_id: medicine_id).first
    if typee == "import"
      if inventory.present?
        inventory.update_attributes import: (inventory.import + number),
                                    endd: inventory.endd + number
      else
        last_inventory = SubInventory.where(issuing_agency_id: issuing_agency_id)
                                  .where("datee < ?", datee)
                                  .where(medicine_id: medicine_id)
                                  .order(datee: :desc).first
        if last_inventory.present?
          last_inventory_end_day = last_inventory.endd
        else
          last_inventory_end_day = 0
        end
        SubInventory.create issuing_agency_id: issuing_agency_id,
                         datee: datee,
                         beginn: last_inventory_end_day,
                         import: number,
                         endd: last_inventory_end_day + number,
                         medicine_id: medicine_id
      end
      inventories = SubInventory.where(issuing_agency_id: issuing_agency_id)
                              .where(medicine_id: medicine_id)
                             .where("datee > ?", datee)
      if inventories.length > 0
        inventories.each do |inventory|
          inventory.update_attributes beginn: inventory.beginn + number,
                                      endd: inventory.endd + number
        end
      end
    else
      if inventory.present?
        inventory.update_attributes export: (inventory.export + number),
                                    endd: (inventory.endd - number)
      else
        last_inventory = SubInventory.where(issuing_agency_id: issuing_agency_id)
                                  .where("datee < ?", datee)
                                  .where(medicine_id: medicine_id)
                                  .order(datee: :desc).first
        if last_inventory.present?
          last_inventory_end_day = last_inventory.endd
        else
          last_inventory_end_day = 0
        end
        SubInventory.create issuing_agency_id: issuing_agency_id,
                         datee: datee,
                         beginn: last_inventory_end_day,
                         export: number,
                         endd: last_inventory_end_day - number,
                         medicine_id: medicine_id
      end
      inventories = SubInventory.where(issuing_agency_id: issuing_agency_id)
                             .where("datee > ?", datee).where(medicine_id: medicine_id)
      if inventories.length > 0
        inventories.each do |inventory|
          inventory.update_attributes beginn: inventory.beginn - number,
                                      endd: inventory.endd - number
        end
      end
    end
  end

  protected

  def require_admin
    authenticate_request!
    if @current_user.role != Settings.role.admin
      render json: {code: 0, message: t("account_permission.denied")}
      return
    end
  end

  def require_admin_agency
    authenticate_request!
    if @current_user.role != Settings.role.admin_agency
      render json: {code: 0, message: t("account_permission.denied")}
      return
    end
  end

  def require_admin_agency_or_admin
    authenticate_request!
    if @current_user.role != Settings.role.admin &&
      @current_user.role != Settings.role.admin_agency
      render json: {code: 0, message: t("account_permission.denied")}
      return
    end
  end

  def save_file_with_token dir, file
    begin
      FileUtils.mkdir_p(dir) unless File.directory?(dir)
      extn = File.extname file.original_filename
      name = File.basename(file.original_filename, extn).gsub(/[^A-z0-9]/, "_")
      full_name = name + "_" + SecureRandom.hex(10) + extn
      full_name = full_name.last(100) if full_name.length > 100
      path = File.join(dir, full_name)
      File.open(path, "wb") { |f| f.write file.read }
      return full_name
    rescue
      return nil
    end
  end

end
