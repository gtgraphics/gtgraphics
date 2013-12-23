class AddFingerprintToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :fingerprint, :string

    reversible do |dir|
      dir.up do
        Message.reset_column_information
        Message.transaction do
          Message.all.each do |message|
            message.generate_fingerprint
            message.save!
          end
        end
      end
    end
  end
end
