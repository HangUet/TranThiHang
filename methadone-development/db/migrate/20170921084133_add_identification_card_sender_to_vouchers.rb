class AddIdentificationCardSenderToVouchers < ActiveRecord::Migration
  def change
    add_column :vouchers, :identification_card_sender, :string
  end
end
