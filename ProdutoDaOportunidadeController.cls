public with sharing class ProdutoDaOportunidadeController {
    private ApexPages.StandardController controller;
    private final Opportunity opp;
    private Opportunity opp1;
    public List<OpportunityLineItem> produtoOportunidade {get; private set;}
    public List<Precos__c> produtosDaTabelaDePrecos {get; private set;}
    public ProdutoDaOportunidadeController(ApexPages.StandardController controller){
        this.controller = controller;
        this.opp = (Opportunity)controller.getRecord();
        opp1 = [Select Id, AccountId,Tipo_de_frete__c from Opportunity where Id = :opp.Id LIMIT 1];
        Account conta = [Select Id, Tabela_de_precos__c from Account where id = :opp1.AccountId LIMIT 1];
        List<Precos__c> precosDaTabela = [Select Id,Produto__c,Preco_CIF__c, Preco_FOB__c,Desconto_em_R__c,Quantidade__c from Precos__c where Tabela_de_precos__c = :conta.Tabela_de_precos__c];
        produtosDaTabelaDePrecos = new List<Precos__c>();
        if (precosDaTabela.size() > 0){
            produtosDaTabelaDePrecos.addAll(precosDaTabela);
        }        
    }
    
    public PageReference save(){
        produtoOportunidade = new List<OpportunityLineItem>(); 
        Double preco;
        for(Precos__c prc : produtosDaTabelaDePrecos){
            if(prc.Quantidade__c != null && prc.Quantidade__c > 0){
                Pricebook2 pb = [Select Id from Pricebook2 where IsStandard = TRUE LIMIT 1];
                PricebookEntry priceBookE = [Select Id from PricebookEntry where Pricebook2Id = :pb.Id and Product2Id = :prc.Produto__c LIMIT 1];
                if (opp1.Tipo_de_frete__c == '1 – CIF RPA' || opp1.Tipo_de_frete__c == '2 – CIF com CTRC'){
                	if (prc.Desconto_em_R__c != NULL && prc.Desconto_em_R__c > 0){
                		preco = prc.Preco_CIF__c - prc.Desconto_em_R__c;
                	}else{
                		preco = prc.Preco_CIF__c;
                	}
                  
                }else{
                	if (prc.Desconto_em_R__c != NULL && prc.Desconto_em_R__c > 0){
                		preco = prc.Preco_FOB__c - prc.Desconto_em_R__c;
                	}else{
                  		preco = prc.Preco_FOB__c;
                	}

                }
                produtoOportunidade.add(new OpportunityLineItem(OpportunityId = opp1.Id,
                                                  PricebookEntryId = priceBookE.Id,
                                                  Quantity = prc.Quantidade__c,
                                                  UnitPrice = preco,
                                                  Desconto_em_RS__c = prc.Desconto_em_R__c));               
            }
        }
        insert produtoOportunidade;
        return null;
    }    
}