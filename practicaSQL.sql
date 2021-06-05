--Ejercicio 1
use GD2015C1;

select clie_codigo Codigo, clie_razon_social RazonSocial
from dbo.Cliente
where clie_limite_credito >= 1000
order by clie_codigo;

--Ejercicio 2
use GD2015C1;

select Producto.prod_codigo Producto, Producto.prod_detalle Detalle
from dbo.Item_Factura
	left join dbo.Producto on Item_Factura.item_producto = Producto.prod_codigo
	left join dbo.Factura on Factura.fact_numero = Item_Factura.item_numero and Factura.fact_sucursal = Item_Factura.item_sucursal and Factura.fact_tipo = Item_Factura.item_tipo
where year(Factura.fact_fecha) = 2012
order by Item_Factura.item_cantidad;

--Ejercicio 3
use GD2015C1;

select Producto.prod_codigo Codigo, Producto.prod_detalle Nombre, STOCK.stoc_cantidad StockTotal
from dbo.Producto
	join dbo.STOCK on Producto.prod_codigo = STOCK.stoc_producto
order by Producto.prod_detalle;

--Ejercicio 4
use GD2015C1;

select Producto.prod_codigo Codigo, Producto.prod_detalle Detalle, count(distinct Composicion.comp_componente) Componentes 
from dbo.Producto
	join dbo.STOCK on Producto.prod_codigo = STOCK.stoc_producto
	left join dbo.Composicion on Composicion.comp_producto = Producto.prod_codigo
group by Producto.prod_codigo, Producto.prod_detalle
having avg(STOCK.stoc_cantidad) > 100;

--Ejercicio 5
use GD2015C1;

select Producto.prod_codigo Codigo, Producto.prod_detalle Detalle, sum(Item_Factura1.item_cantidad) Cantidad
from dbo.Producto 
	left join dbo.Item_Factura Item_Factura1 on Item_Factura1.item_producto = Producto.prod_codigo
	left join dbo.Factura 
		on Factura.fact_numero = Item_Factura1.item_numero
		and Factura.fact_sucursal = Item_Factura1.item_sucursal
		and Factura.fact_tipo = Item_Factura1.item_tipo
where year(Factura.fact_fecha) = 2012
group by Producto.prod_codigo, Producto.prod_detalle
having sum(Item_Factura1.item_cantidad) > (select sum(Item_Factura2.item_cantidad)
	from dbo.Item_Factura Item_Factura2
		join dbo.Factura 
			on Factura.fact_numero = Item_Factura2.item_numero
			and Factura.fact_sucursal = Item_Factura2.item_sucursal
			and Factura.fact_tipo = Item_Factura2.item_tipo
	where year(Factura.fact_fecha) = 2011 and Producto.prod_codigo = Item_Factura2.item_producto);

--Ejercicio 6
use GD2015C1;

select Rubro.rubr_id Rubro, Rubro.rubr_detalle Detalle, count(distinct Producto.prod_codigo) CantidadArticulos, sum(STOCK1.stoc_cantidad) StockTotal
from dbo.Rubro
	left join dbo.Producto on Rubro.rubr_id = Producto.prod_rubro
	left join dbo.STOCK STOCK1 on STOCK1.stoc_producto = Producto.prod_codigo
group by Rubro.rubr_id, Rubro.rubr_detalle
having sum(STOCK1.stoc_cantidad) > (select sum(STOCK2.stoc_cantidad)
	from dbo.STOCK STOCK2
	where STOCK2.stoc_producto = '00000000' and STOCK2.stoc_deposito = '00');

--Ejercicio 7
use GD2015C1;

select Producto.prod_codigo CodigoArticulo, Producto.prod_detalle Detalle, max(Item_Factura.item_precio) MayorPrecio, min(Item_Factura.item_precio) MenorPrecio, cast((max(Item_Factura.item_precio) - min(Item_Factura.item_precio))/min(Item_Factura.item_precio)*100 as decimal(10,2)) PorcentajeDiferencia
from dbo.Producto
	join dbo.Item_Factura on Producto.prod_codigo = Item_Factura.item_producto
	left join dbo.STOCK on STOCK.stoc_producto = Producto.prod_codigo
where STOCK.stoc_cantidad is not null and STOCK.stoc_cantidad > 0
group by Producto.prod_codigo, Producto.prod_detalle;

--Ejercicio 8
select Producto.prod_detalle NombreArticulo, max(STOCK1.stoc_cantidad) MaxStock
from dbo.STOCK STOCK1
	join dbo.Producto on Producto.prod_codigo = STOCK1.stoc_producto
where STOCK1.stoc_cantidad > 0
group by Producto.prod_codigo, Producto.prod_detalle
having count(distinct STOCK1.stoc_deposito) = (select count(*) from dbo.DEPOSITO);

--Ejercicio 9
select Empleado.empl_jefe CodigoJefe, Empleado.empl_codigo CodigoEmpleado, (rtrim(Empleado.empl_nombre) + ' ' + Empleado.empl_apellido) NombreEmpleado, (select count(*) from dbo.DEPOSITO where DEPOSITO.depo_encargado = Empleado.empl_codigo) DepositosEmpleado, (select count(*) from dbo.DEPOSITO where DEPOSITO.depo_encargado = Empleado.empl_jefe) DepositosJefe 
from dbo.Empleado
	left join dbo.DEPOSITO on Empleado.empl_codigo = DEPOSITO.depo_encargado
where DEPOSITO.depo_encargado = Empleado.empl_codigo;

--Ejercicio 10
select Producto.prod_codigo CodigoProducto, Producto.prod_detalle NombreProducto,
		(select top 1 Cliente.clie_codigo CodigoCliente
		from dbo.Item_Factura
			left join dbo.Factura on Factura.fact_numero = Item_Factura.item_numero
				and Factura.fact_sucursal = Item_Factura.item_sucursal
				and Factura.fact_tipo = Item_Factura.item_tipo
			join dbo.Cliente on Factura.fact_cliente = Factura.fact_cliente
		where Item_Factura.item_producto = Producto.prod_codigo
		group by Cliente.clie_codigo
		order by sum(Item_Factura.item_cantidad) desc) ClienteMayorCompra
from dbo.Producto
where Producto.prod_codigo in
	(select top 10 Item_Factura.item_producto 
	from dbo.Item_Factura
	group by Item_Factura.item_producto
	order by sum(Item_Factura.item_cantidad) desc)
	or Producto.prod_codigo in (select top 10 Item_Factura.item_producto 
	from dbo.Item_Factura
	group by Item_Factura.item_producto
	order by sum(Item_Factura.item_cantidad) asc);

--Ejercicio 11
select Familia.fami_detalle DetalleFamilia, count(distinct Producto.prod_codigo) CantidadDifProductos, sum(Factura.fact_total) SumaTotal
from dbo.Familia 
	join dbo.Producto on Producto.prod_familia = Familia.fami_id
	left join dbo.Item_Factura on Item_Factura.item_producto = Producto.prod_codigo
	left join dbo.Factura on Factura.fact_numero = Item_Factura.item_numero
group by Familia.fami_detalle, Familia.fami_id
having (select sum(Factura.fact_total) 
	from dbo.Factura
		join Item_Factura on Factura.fact_numero = Item_Factura.item_numero
			and Factura.fact_sucursal = Item_Factura.item_sucursal
			and Factura.fact_tipo = Item_Factura.item_tipo
		join dbo.Producto on Item_Factura.item_producto = Producto.prod_codigo
	where year(Factura.fact_fecha) = 2012 and Producto.prod_familia = Familia.fami_id) > 20000
order by 2 desc;

--Ejercicio 12
use GD2015C1;

select Producto.prod_detalle NombreProducto, avg(Item_Factura.item_precio) ImportePromedio, 
	count(distinct Factura.fact_cliente) CantidadClientes, 
	isnull((select count(distinct STOCK.stoc_deposito) from dbo.STOCK 
		where STOCK.stoc_producto = Producto.prod_codigo
		and STOCK.stoc_cantidad > 0
		group by STOCK.stoc_producto),0) CantidadDepositos,
	isnull((select sum(STOCK.stoc_cantidad) from dbo.STOCK 
		where STOCK.stoc_producto = Producto.prod_codigo
		group by STOCK.stoc_producto),0) StockActualProducto
from dbo.Producto 
	join dbo.Item_Factura on Item_Factura.item_producto = Producto.prod_codigo
	join dbo.Factura on Item_Factura.item_tipo = Factura.fact_tipo
		and Factura.fact_sucursal = Item_Factura.item_sucursal
		and Factura.fact_numero = Item_Factura.item_numero
where exists
	(select Item_Factura.item_producto 
	from dbo.Item_Factura Item_Factura2
		join dbo.Factura on Item_Factura2.item_tipo = Factura.fact_tipo
		and Factura.fact_sucursal = Item_Factura2.item_sucursal
		and Factura.fact_numero = Item_Factura2.item_numero
	where year(Factura.fact_fecha) = 2012
		and Item_Factura2.item_producto = Producto.prod_codigo)
group by Producto.prod_codigo,Producto.prod_detalle 
order by sum(Item_Factura.item_cantidad * Item_Factura.item_precio) desc;

--Ejercicio 13
select Producto1.prod_detalle NombreProducto, Producto1.prod_precio PrecioProducto, 
	 sum(Composicion.comp_cantidad*Producto2.prod_precio) PrecioComponentes
from dbo.Composicion
	join dbo.Producto Producto1 on Producto1.prod_codigo = Composicion.comp_producto
	join dbo.Producto Producto2 on Producto2.prod_codigo = Composicion.comp_componente
group by Producto1.prod_codigo, Producto1.prod_detalle, Producto1.prod_precio, Composicion.comp_producto
having count(distinct Composicion.comp_componente) > 2
order by count(distinct Composicion.comp_componente) desc;

--Ejercicio 14
select Factura1.fact_cliente CodCliente, isnull(count(distinct Factura1.fact_numero),0) CantVeces,
	isnull((select avg(Factura2.fact_total) from dbo.Factura Factura2 
		where Factura2.fact_cliente = Factura1.fact_cliente
		and year(Factura2.fact_fecha) = (select max(year(Factura4.fact_fecha)) from dbo.Factura Factura4)),0) PromedioCompra,
	isnull(count(distinct Item_Factura.item_producto),0) CantidadProductosDif,
	isnull(max(Factura1.fact_total),0) MontoMayorCompra
from dbo.Factura Factura1
	join dbo.Item_Factura on Factura1.fact_numero = Item_Factura.item_numero
where year(Factura1.fact_fecha) = (select max(year(Factura3.fact_fecha)) from dbo.Factura Factura3)
group by Factura1.fact_cliente
order by count(distinct Factura1.fact_numero) desc;

--Ejercicio 15
select count(*) Cantidad,
	(select distinct Producto.prod_codigo from dbo.Producto 
		where Producto.prod_codigo = Item1.item_producto) CodigoItem1,
	(select distinct Producto.prod_detalle from dbo.Producto 
		where Producto.prod_codigo = Item1.item_producto) DetalleItem1,
	(select distinct Producto.prod_codigo from dbo.Producto 
		where Producto.prod_codigo = Item2.item_producto) CodigoItem2,
	(select distinct Producto.prod_detalle from dbo.Producto 
		where Producto.prod_codigo = Item2.item_producto) DetalleItem2
from Item_Factura Item1 
	join Item_Factura Item2 on Item1.item_numero = Item2.item_numero
where Item1.item_numero = Item2.item_numero and
	Item1.item_sucursal = Item2.item_sucursal and
	Item1.item_tipo = Item2.item_tipo and
	Item1.item_producto != Item2.item_producto and
	Item1.item_producto > Item2.item_producto
group by Item1.item_producto, Item2.item_producto
having count(*) > 500
order by 1;

--Ejercicio 16
use GD2015C1;

select Cliente.clie_razon_social NombreCliente, isnull(sum(Item_Factura.item_cantidad),0) CantidadUnidades,
	isnull((select top 1 Item_Factura.item_producto
	from dbo.Item_Factura
		join Factura on Factura.fact_numero = Item_Factura.item_numero
	where Factura.fact_cliente = Cliente.clie_codigo and year(Factura.fact_fecha) = 2012
	group by Factura.fact_cliente, Item_Factura.item_producto
	order by sum(Item_Factura.item_cantidad) desc, Item_Factura.item_producto asc),0) CodigoProductoMaxVenta
from dbo.Cliente
	join dbo.Factura on Cliente.clie_codigo = Factura.fact_cliente
	join dbo.Item_Factura on Item_Factura.item_numero = Factura.fact_numero
where year(Factura.fact_fecha) = 2012
group by Cliente.clie_codigo, Cliente.clie_razon_social, Cliente.clie_domicilio--, Item_Factura.item_numero
having (select sum(Item_Factura.item_cantidad)
		from dbo.Item_Factura
			join dbo.Factura on Item_Factura.item_numero = Factura.fact_numero
		where Factura.fact_cliente = Cliente.clie_codigo
		group by Factura.fact_cliente) < 1/3 *
		(select top 1 avg(Item_Factura.item_cantidad)
		from dbo.Item_Factura
			join dbo.Factura on Item_Factura.item_numero = Factura.fact_numero
		where (select top 1 Item_Factura.item_producto
				from dbo.Item_Factura
					join dbo.Factura on Item_Factura.item_numero = Factura.fact_numero
				where year(Factura.fact_fecha) = 2012
				group by Item_Factura.item_producto
				order by sum(Item_Factura.item_cantidad) desc) = Item_Factura.item_producto
		group by Item_Factura.item_producto
		order by sum(Item_Factura.item_cantidad) desc)
order by Cliente.clie_domicilio asc;


















