import { classes } from 'common/react';
import { useBackend } from '../backend';
import { Box, Button, Section, Table } from '../components';
import { Window } from '../layouts';

const VendingRow = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    product,
    productStock,
    custom,
  } = props;
  const free = (
    !data.onstation
    || product.price === 0
    || (
      !product.extended
      && data.department
      && data.user
      && data.department === data.user.department
    )
    // yogs start -- patch to make ignores_capitalism work again
    || data.ignores_capitalism
    // yogs end
  );

  const customFree = (
    !data.onstation
    || (
      data.user
      && data.department
      && data.department === data.user.department
    )
    || data.ignores_capitalism
  );

  return (
    <Table.Row>
      <Table.Cell collapsing>
        {product.base64 ? (
          <img
            src={`data:image/jpeg;base64,${product.img}`}
            className="icon"
            style={{
              'vertical-align': 'middle',
              'horizontal-align': 'middle',
            }} />
        ) : (
          <span
            className={classes([
              'vending32x32',
              product.path,
            ])}
            style={{
              'vertical-align': 'middle',
              'horizontal-align': 'middle',
            }} />
        )}
      </Table.Cell>
      <Table.Cell bold>
        {product.name}
      </Table.Cell>
      <Table.Cell collapsing textAlign="center">
        <Box
          color={custom ? (productStock > 0 ? 'good' : 'bad')
            : productStock <= 0
              ? 'bad'
              : productStock <= (product.max_amount / 2)
                ? 'average'
                : 'good'}>
          {productStock} in stock
        </Box>
      </Table.Cell>
      <Table.Cell collapsing textAlign="center">
        {custom && (
          <Button
            fluid
            disabled={(
              productStock === 0
              || !data.user
              || (!free && product.price > data.user.cash)
            )}
            content={customFree ? 'FREE' : product.price + ' cr'}
            onClick={() => act('vend_custom', {
              'item': product.name,
            })} />
        ) || (
          <Button
            fluid
            disabled={(
              productStock === 0
              || !free && (
                !data.user
                || product.price > data.user.cash
              )
            )}
            content={free ? 'FREE' : product.price + ' cr'}
            onClick={() => act('vend', {
              'ref': product.ref,
            })} />
        )}
      </Table.Cell>
    </Table.Row>
  );
};

export const Vending = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    product_ad,
    chef,
  } = data;
  let inventory;
  if (data.extended_inventory) {
    inventory = [
      ...data.product_records,
      ...data.coin_records,
      ...data.hidden_records,
    ];
  } else {
    inventory = [
      ...data.product_records,
      ...data.coin_records,
    ];
  }

  const customInventory = Object.keys(data.custom_stock).map(itemName => ({
    product: {
      name: itemName,
      price: chef.price,
      base64: true,
      img: data.custom_stock[itemName].img,
    },
    productStock: data.custom_stock[itemName].amount,
  }));

  return (
    <Window
      title="Vending Machine"
      width={450}
      height={600}>
      <Window.Content scrollable>
        {product_ad && (
          <Section textAlign="center" textColor="green">
            {product_ad}
          </Section>
        )}
        {!!data.onstation && (
          <Section title="User">
            {data.user && (
              <Box>
                Welcome, <b>{data.user.name}</b>,
                {' '}
                <b>{data.user.job || 'Unemployed'}</b>!
                <br />
                Your balance is <b>{data.user.cash} credits</b>.
              </Box>
            ) || (
              <Box color="light-gray">
                No registered ID card!<br />
                Please contact your local HoP!
              </Box>
            )}
          </Section>
        )}
        {!!customInventory.length &&
        <Section title={chef.title} >
          <Table>
            {customInventory.map(customItem => (
              <VendingRow
                key={customItem.product.name}
                custom
                product={customItem.product}
                productStock={customItem.productStock}
              />
            ))}
          </Table>
        </Section>}
        <Section title="Products" >
          <Table>
            {inventory.map(product => (
              <VendingRow
                key={product.name}
                product={product}
                productStock={data.stock[product.name]} />
            ))}
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};
