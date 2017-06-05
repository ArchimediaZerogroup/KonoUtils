require_relative '../../rails_helper'

#cd KonoUtils/spec && rspec lib/kono_utils/fiscal_code_spec.rb

module KonoUtils
  describe FiscalCode do

    it "ControllaCF" do

      expect {
        KonoUtils::FiscalCode::ControllaCF.valid?("")
      }.to raise_error(KonoUtils::FiscalCode::ControllaCF::EmptyString)

      expect {
        KonoUtils::FiscalCode::ControllaCF.valid?("GHDJRU")
      }.to raise_error(KonoUtils::FiscalCode::ControllaCF::InvalidLength)

      expect {
        KonoUtils::FiscalCode::ControllaCF.valid?("rssmra80a01h501u", true)
      }.to raise_error(KonoUtils::FiscalCode::ControllaCF::CaseError)

      expect(
          KonoUtils::FiscalCode::ControllaCF.valid?("RSSMRA80A01H501U", true)
      ).to be_truthy

      expect(
          KonoUtils::FiscalCode::ControllaCF.valid?("RSSMRA80A01H501J", true)
      ).to be_falsey

      expect(
          KonoUtils::FiscalCode::ControllaCF.valid?("RSSMRA43S18L750G", true)
      ).to be_truthy
    end

    it "ControllaPI" do
      expect {
        KonoUtils::FiscalCode::ControllaPI.valid?("")
      }.to raise_error(KonoUtils::FiscalCode::ControllaPI::EmptyString)

      expect {
        KonoUtils::FiscalCode::ControllaPI.valid?("020405902")
      }.to raise_error(KonoUtils::FiscalCode::ControllaPI::InvalidLength)

      expect(
          KonoUtils::FiscalCode::ControllaPI.valid?("02040830982")
      ).to be_truthy

      expect(
          KonoUtils::FiscalCode::ControllaPI.valid?("02040830989")
      ).to be_falsey

    end


  end
end