package org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.expression.provider;

import java.util.Arrays;
import java.util.Collection;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

import org.eclipse.emf.common.notify.AdapterFactory;
import org.eclipse.emf.common.notify.Notification;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.emf.edit.provider.ViewerNotification;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.expression.LhsEnumCharacteristicReference;
import org.palladiosimulator.dataflow.dictionary.characterized.DataDictionaryCharacterized.CharacteristicType;
import org.palladiosimulator.dataflow.dictionary.characterized.DataDictionaryCharacterized.EnumCharacteristicType;
import org.palladiosimulator.dataflow.dictionary.characterized.DataDictionaryCharacterized.Literal;
import org.palladiosimulator.dataflow.dictionary.characterized.DataDictionaryCharacterized.expressions.ExpressionsPackage;

import tools.mdsd.library.emfeditutils.itempropertydescriptor.ItemPropertyDescriptorUtils;
import tools.mdsd.library.emfeditutils.itempropertydescriptor.ValueChoiceCalculatorBase;

public class LhsEnumCharacteristicReferenceItemProvider extends LhsEnumCharacteristicReferenceItemProviderGen {

    private static final Set<EStructuralFeature> LABEL_FEATURES = new HashSet<>(
            Arrays.asList(ExpressionsPackage.Literals.ENUM_CHARACTERISTIC_REFERENCE__LITERAL,
                    ExpressionsPackage.Literals.CHARACTERISTIC_REFERENCE__CHARACTERISTIC_TYPE));

    public LhsEnumCharacteristicReferenceItemProvider(AdapterFactory adapterFactory) {
        super(adapterFactory);
    }

    @Override
    protected void addLiteralPropertyDescriptor(Object object) {
        super.addLiteralPropertyDescriptor(object);
        var decorator = ItemPropertyDescriptorUtils.decorateLastDescriptor(itemPropertyDescriptors);
        decorator.setValueChoiceCalculator(
                new ValueChoiceCalculatorBase<>(LhsEnumCharacteristicReference.class, Literal.class) {
                    @Override
                    protected Collection<?> getValueChoiceTyped(LhsEnumCharacteristicReference object,
                            List<Literal> typedList) {
                        return Optional.of(object)
                            .map(LhsEnumCharacteristicReference::getCharacteristicType)
                            .filter(EnumCharacteristicType.class::isInstance)
                            .map(EnumCharacteristicType.class::cast)
                            .map(EnumCharacteristicType::getType)
                            .map(e -> typedList.stream()
                                .filter(literal -> literal == null || e.getLiterals()
                                    .contains(literal))
                                .collect(Collectors.toList()))
                            .orElse(typedList);
                    }
                });
    }

    @Override
    public void notifyChanged(Notification notification) {
        if (LABEL_FEATURES.contains(notification.getFeature())) {
            fireNotifyChanged(new ViewerNotification(notification, notification.getNotifier(), false, true));
        }
        super.notifyChanged(notification);
    }

    @Override
    public String getText(Object object) {
        if (object instanceof LhsEnumCharacteristicReference) {
            var reference = (LhsEnumCharacteristicReference) object;
            var typeSegment = Optional.ofNullable(reference.getCharacteristicType())
                .map(CharacteristicType::getName)
                .orElse("*");
            var literalSegment = Optional.ofNullable(reference.getLiteral())
                .map(Literal::getName)
                .orElse("*");
            return String.format("%s.%s", typeSegment, literalSegment);
        }
        return super.getText(object);
    }

}
