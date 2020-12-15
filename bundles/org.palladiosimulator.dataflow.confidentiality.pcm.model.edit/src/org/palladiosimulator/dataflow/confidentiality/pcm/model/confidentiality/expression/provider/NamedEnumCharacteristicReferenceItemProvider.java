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
import org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.expression.ExpressionPackage;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.expression.NamedEnumCharacteristicReference;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.util.LabelFeatureMonitoringAdapter;
import org.palladiosimulator.dataflow.dictionary.characterized.DataDictionaryCharacterized.CharacteristicType;
import org.palladiosimulator.dataflow.dictionary.characterized.DataDictionaryCharacterized.EnumCharacteristicType;
import org.palladiosimulator.dataflow.dictionary.characterized.DataDictionaryCharacterized.Literal;
import org.palladiosimulator.dataflow.dictionary.characterized.DataDictionaryCharacterized.expressions.ExpressionsPackage;

import de.uka.ipd.sdq.stoex.AbstractNamedReference;
import de.uka.ipd.sdq.stoex.StoexPackage;
import tools.mdsd.library.emfeditutils.itempropertydescriptor.ItemPropertyDescriptorUtils;
import tools.mdsd.library.emfeditutils.itempropertydescriptor.ValueChoiceCalculatorBase;

public class NamedEnumCharacteristicReferenceItemProvider extends NamedEnumCharacteristicReferenceItemProviderGen {

    private static final Set<EStructuralFeature> LABEL_FEATURES = new HashSet<>(
            Arrays.asList(ExpressionsPackage.Literals.ENUM_CHARACTERISTIC_REFERENCE__LITERAL,
                    ExpressionsPackage.Literals.CHARACTERISTIC_REFERENCE__CHARACTERISTIC_TYPE,
                    StoexPackage.Literals.ABSTRACT_NAMED_REFERENCE__REFERENCE_NAME));

    /**
     * {@inheritDoc}
     */
    public NamedEnumCharacteristicReferenceItemProvider(AdapterFactory adapterFactory) {
        super(adapterFactory);
    }

    @Override
    protected void addLiteralPropertyDescriptor(Object object) {
        super.addLiteralPropertyDescriptor(object);
        var decorator = ItemPropertyDescriptorUtils.decorateLastDescriptor(itemPropertyDescriptors);
        decorator.setValueChoiceCalculator(
                new ValueChoiceCalculatorBase<>(NamedEnumCharacteristicReference.class, Literal.class) {
                    @Override
                    protected Collection<?> getValueChoiceTyped(NamedEnumCharacteristicReference object,
                            List<Literal> typedList) {
                        return Optional.of(object)
                            .map(NamedEnumCharacteristicReference::getCharacteristicType)
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
            var notifier = notification.getNotifier();
            if (notifier instanceof AbstractNamedReference) {
                notifier = ((AbstractNamedReference) notifier).eContainer();
            }
            fireNotifyChanged(new ViewerNotification(notification, notifier, false, true));
        }
        if (notification
            .getFeature() == ExpressionPackage.Literals.ABSTRACT_NAMED_REFERENCE_REFERENCE__NAMED_REFERENCE) {
            LabelFeatureMonitoringAdapter.handleFeatureChange(notification, this::notifyChanged);
        }
        super.notifyChanged(notification);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public String getText(Object object) {
        if (object instanceof NamedEnumCharacteristicReference) {
            var reference = (NamedEnumCharacteristicReference) object;
            var namePart = Optional.ofNullable(reference.getNamedReference())
                .map(AbstractNamedReference::getReferenceName)
                .orElse("INVALID");
            var typePart = Optional.ofNullable(reference.getCharacteristicType())
                .map(CharacteristicType::getName)
                .orElse("*");
            var literalPart = Optional.ofNullable(reference.getLiteral())
                .map(Literal::getName)
                .orElse("*");
            return String.format("%s.%s.%s", namePart, typePart, literalPart);
        }
        return super.getText(object);
    }

}
