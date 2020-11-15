package org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.characteristics.provider;

import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import org.eclipse.emf.common.notify.AdapterFactory;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.characteristics.EnumCharacteristic;
import org.palladiosimulator.dataflow.dictionary.characterized.DataDictionaryCharacterized.Literal;
import org.palladiosimulator.pcm.core.entity.Entity;

import tools.mdsd.library.emfeditutils.itempropertydescriptor.ItemPropertyDescriptorUtils;
import tools.mdsd.library.emfeditutils.itempropertydescriptor.ValueChoiceCalculatorBase;

public class EnumCharacteristicItemProvider extends EnumCharacteristicItemProviderGen {

    /**
     * {@inheritDoc}
     */
    public EnumCharacteristicItemProvider(AdapterFactory adapterFactory) {
        super(adapterFactory);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    protected void addValuesPropertyDescriptor(Object object) {
        super.addValuesPropertyDescriptor(object);
        var decorator = ItemPropertyDescriptorUtils.decorateLastDescriptor(itemPropertyDescriptors);
        decorator.setValueChoiceCalculator(new ValueChoiceCalculatorBase<>(EnumCharacteristic.class, Literal.class) {
            @Override
            protected Collection<?> getValueChoiceTyped(EnumCharacteristic object, List<Literal> typedList) {
                return Optional.of(object)
                    .map(EnumCharacteristic::getType)
                    .map(type -> typedList.stream()
                        .filter(literal -> literal == null || type.getType()
                            .getLiterals()
                            .contains(literal))
                        .collect(Collectors.toList()))
                    .orElse(typedList);
            }
        });
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public String getText(Object object) {
        var entity = Optional.ofNullable(object)
            .filter(Entity.class::isInstance)
            .map(Entity.class::cast);
        var type = getString("_UI_EnumCharacteristic_type");
        var name = entity.map(Entity::getEntityName)
            .orElse("");
        var id = entity.map(Entity::getId)
            .orElse("");
        return String.format("%s %s (%s)", type, name, id);
    }

}
