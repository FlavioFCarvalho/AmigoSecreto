class RaffleService

    #Construtor da classe
    def initialize(campaign)
      @campaign = campaign
    end
  
    def call
      #Verifica se existe pelo menos 3 membros na campanha  
      return false if @campaign.members.count < 3
  
      #Seta um hash vazio
      results = {}
      #Todos o usuários
      members_list = @campaign.members
      #Todos os usuários que ele pode tirar
      friends_list = @campaign.members
      i = 0
      while(members_list.count != i)
        m = members_list[i]
        i += 1
  
        #Serve para pegar uma amigo 
        loop do
          #Traz um amigo aleatóriamente  
          friend = friends_list.sample
  
          #Não permite que o usuário tire ele mesmo
          if friends_list.count == 1 and friend == m
            results = {}
            members_list = @campaign.members
            friends_list = @campaign.members
            break
          elsif friend != m and results[friend] != m
            results[m] = friend
            friends_list -= [friend]
            break
          end
        end
      end
      results
    end
  end