require "rails_helper"

RSpec.describe CampaignMailer, type: :mailer do
  describe "raffle" do

    before do
      @campaign = create(:campaign)
      @member   = create(:member, campaign: @campaign)
      #Envia o e-mail da campanha
      @mail = CampaignMailer.raffle(@campaign, @member, @friend)
    end


    #Confere os dados do cabeçalho do e-mail
    it "renders the headers" do
      expect(@mail.subject).to eq("Nosso Amigo Secreto: #{@campaign.title}")
      expect(@mail.to).to eq([@member.email])
    end

    #Checa se que está recebendo o e-mail é realmente para quem foi enviado via cabeçalho
    it "body have member name" do
      expect(@mail.body.encoded).to match(@member.name)
    end

    #Checa se o dono da campanha recebeu o e-mail
    it "body have campaign creator name" do
      expect(@mail.body.encoded).to match(@campaign.user.name)
    end

    #Verifica se o membro abriu o e-mail
    it "body have member link to set open" do
      expect(@mail.body.encoded).to match("/members/#{@member.token}/opened")
    end
  end

end