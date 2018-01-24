require 'rails_helper'

RSpec.describe CampaignsController, type: :controller do
  include Devise::Test::ControllerHelpers

  #Antes chama o map do devise, depois cria um usuário e depois loga com ele.
  before(:each) do
    # request.env["HTTP_ACCEPT"] = 'application/json'

    @request.env["devise.mapping"] = Devise.mappings[:user]
    @current_user = FactoryBot.create(:user)
    sign_in @current_user
  end

  #Verifica se a página index existe.
  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #show" do
    #Verifica se existe uma campanha
    context "campaing exists" do
      #Verifica se um usuario é dono de uma campanha.
      context "User is the owner of the campaing" do
        it "Returns success" do
          campaign = create(:campaign, user: @current_user)
          get :show, params: {id: campaign.id}
          expect(response).to have_http_status(:success)
        end
      end
      #Verifica se um usuário é dono de uma campanha
      context "User is not the owner of the campaign" do
        it "Redirects to root" do
          campaign = create(:campaign)
          get :show, params: {id: campaign.id}
          #Se não for dono é redirecionado para a home 
          expect(response).to redirect_to('/')
        end
      end
    end
     
    #Verifica se uma campanha não existe
    context "campaign don't exists" do
      it "Redirects to root" do
        get :show, params: {id: 0}
        #Se não achar redireciona para a home
        expect(response).to redirect_to('/')
      end
    end
  end


  describe "POST #create" do
    before(:each) do
      #Gera os atributos de uma campanha
      @campaign_attributes = attributes_for(:campaign, user: @current_user)
      #Manda um post para criar uma campanha
      post :create, params: {campaign: @campaign_attributes}
    end

    #Após criar uma campanha redireciona para a própria campanha
    it "Redirect to new campaign" do
      expect(response).to have_http_status(302)
      expect(response).to redirect_to("/campaigns/#{Campaign.last.id}")
    end

    #Criando campanha passando os atributos
    it "Create campaign with right attributes" do
      expect(Campaign.last.user).to eql(@current_user)
      expect(Campaign.last.title).to eql(@campaign_attributes[:title])
      expect(Campaign.last.description).to eql(@campaign_attributes[:description])
      expect(Campaign.last.status).to eql('pending')
    end

    #Verifica se o membro q criou a campanha está associado a ela
    it "Create campaign with owner associated as a member" do
      expect(Campaign.last.members.last.name).to eql(@current_user.name)
      expect(Campaign.last.members.last.email).to eql(@current_user.email)
    end
  end

  describe "DELETE #destroy" do
    #Seta a campanha via json para deixar mais dinâmico
    before(:each) do
      request.env["HTTP_ACCEPT"] = 'application/json'
    end

    #Quando é dono da campanha
    context "User is the Campaign Owner" do
      it "returns http success" do
        #Cria a campanha
        campaign = create(:campaign, user: @current_user)
        #Deleta a campanha
        delete :destroy, params: {id: campaign.id}
        #Recebe o status de sucesso
        expect(response).to have_http_status(:success)
      end
    end

    #Quando não é dono da campanha
    context "User isn't the Campaign Owner" do
      it "returns http forbidden" do
        campaign = create(:campaign)
        delete :destroy, params: {id: campaign.id}
        #Recebe um forbidden
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "PUT #update" do
    before(:each) do
      @new_campaign_attributes = attributes_for(:campaign)
      request.env["HTTP_ACCEPT"] = 'application/json'
    end

    #Quando é dono da campnha
    context "User is the Campaign Owner" do
      before(:each) do
        campaign = create(:campaign, user: @current_user)
        put :update, params: {id: campaign.id, campaign: @new_campaign_attributes}
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "Campaign have the new attributes" do
        expect(Campaign.last.title).to eq(@new_campaign_attributes[:title])
        expect(Campaign.last.description).to eq(@new_campaign_attributes[:description])
      end
    end
   
    #Quando não é dono da campanha
    context "User isn't the Campaign Owner" do
      it "returns http forbidden" do
        campaign = create(:campaign)
        put :update, params: {id: campaign.id, campaign: @new_campaign_attributes}
        #Recebe um forbidden
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  #Testa o sorteio da campanha
  describe "GET #raffle" do
    before(:each) do
      request.env["HTTP_ACCEPT"] = 'application/json'
    end

    #O usuário é o dono da campanha
    context "User is the Campaign Owner" do
      before(:each) do
        @campaign = create(:campaign, user: @current_user)
      end
       
      #Quando tem mais de dois membros
      context "Has more than two members" do
        before(:each) do
          #Cria 3 membros associados a campanha , mais o dono da campanha 
          #que será automaticamente adicionado
          create(:member, campaign: @campaign)
          create(:member, campaign: @campaign)
          create(:member, campaign: @campaign)
          #Realiza o sorteio
          post :raffle, params: {id: @campaign.id}
        end

        it "returns http success" do
          expect(response).to have_http_status(:success)
        end
      end
       
      #Quando não tem mais de dois membros
      context "No more than two members" do
        before(:each) do
          create(:member, campaign: @campaign)
          post :raffle, params: {id: @campaign.id}
        end

        #Não realiza o sorteio
        it "returns http success" do
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
    
    #O usuário não é o dono da campanha
    context "User isn't the Campaign Owner" do
      before(:each) do
        #Cria a campanha
        @campaign = create(:campaign)
        post :raffle, params: {id: @campaign.id}
      end
      
       #Recebe um forbidden
      it "returns http forbidden" do
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end