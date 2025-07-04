import { Button, LabeledList } from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';

import { useBackend } from '../../backend';
import { OperatorData } from './data';

export const PowerModulesPane = () => {
  const { act, data } = useBackend<OperatorData>();
  const { mech_equipment, mineral_material_amount } = data;
  return (
    <LabeledList>
      {mech_equipment['power'].map((module, i) => (
        <LabeledList.Item
          key={i}
          label={
            module.name +
            (module.snowflake.fuel === null
              ? ''
              : ': ' +
                toFixed(module.snowflake.fuel * mineral_material_amount, 0.1) +
                ' cm³')
          }
        >
          <Button
            content={(module.activated ? 'En' : 'Dis') + 'abled'}
            selected={module.activated}
            onClick={() =>
              act('equip_act', {
                ref: module.ref,
                gear_action: 'toggle',
              })
            }
          />
          <Button
            content={'Detach'}
            onClick={() =>
              act('equip_act', {
                ref: module.ref,
                gear_action: 'detach',
              })
            }
          />
        </LabeledList.Item>
      ))}
    </LabeledList>
  );
};
