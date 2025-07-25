use restaurante;

create view resumo_pedido as
select pedidos.id_pedido, pedidos.quantidade, pedidos.data_pedido, clientes.nome as clientes, clientes.email, funcionarios.nome as funcionario, 
produtos.nome as produto, produtos.preco
from pedidos 
join clientes on clientes.id_cliente = pedidos.id_cliente
join produtos on produtos.id_produto = pedidos.id_produto
join funcionarios on funcionarios.id_funcionario = pedidos.id_funcionario;


select id_pedido, clientes, sum(quantidade * preco) as total from resumo_pedido group by id_pedido;

create or replace view resumo_pedido as
select pedidos.id_pedido, pedidos.quantidade, pedidos.data_pedido, clientes.nome as clientes, clientes.email, funcionarios.nome as funcionario, 
produtos.nome as produto, produtos.preco, sum(pedidos.quantidade * produtos.preco) as total
from pedidos 
join clientes on clientes.id_cliente = pedidos.id_cliente
join produtos on produtos.id_produto = pedidos.id_produto
join funcionarios on funcionarios.id_funcionario = pedidos.id_funcionario
group by pedidos.id_pedido, pedidos.quantidade, pedidos.data_pedido, clientes.nome, clientes.email, funcionarios.nome, 
produtos.nome, produtos.preco;

select id_pedido, clientes, total from resumo_pedido
group by id_pedido, clientes, total order by id_pedido;

explain
select id_pedido, clientes, total from resumo_pedido
group by id_pedido, clientes, total order by id_pedido;

delimiter //
create function busca_ingredientes_produto(idProduto int)
returns varchar(200)
reads sql data
begin
	declare ingredientesProduto varchar(200);
    select ingredientes into ingredientesProduto from info_produtos where id_produto = idProduto;
    return ingredientesProduto;
end //
delimiter ;

select busca_ingredientes_produto(10);

delimiter //
create function mediaPedido(pedido_id INT)
returns varchar(50)
reads sql data
begin
    declare total_pedido decimal(10,2);
    declare media_total decimal(10,2);
    declare resultado varchar(50);
    
    select total into total_pedido from resumo_pedido where id_pedido = pedido_id;
	select avg(total) into media_total from resumo_pedido;

		if total_pedido > media_total then
			set resultado = 'Acima da média';
		elseif total_pedido < media_total then
			set resultado = 'Abaixo da média';
		else
			set resultado = 'Igual à média';
		end if;

    return resultado;
end //

delimiter ;

select mediaPedido(5);
select mediaPedido(6);

