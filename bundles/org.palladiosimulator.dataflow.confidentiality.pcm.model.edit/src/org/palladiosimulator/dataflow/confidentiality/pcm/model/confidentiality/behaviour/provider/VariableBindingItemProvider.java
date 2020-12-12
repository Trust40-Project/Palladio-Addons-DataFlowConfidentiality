package org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.behaviour.provider;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;

import org.eclipse.emf.common.notify.AdapterFactory;
import org.eclipse.emf.common.notify.Notification;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.emf.edit.provider.ViewerNotification;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.behaviour.BehaviourPackage;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.behaviour.BehaviourReuse;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.behaviour.VariableBinding;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.impl.NamedReferenceUtils;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.util.LabelFeatureMonitoringAdapter;

import de.uka.ipd.sdq.stoex.AbstractNamedReference;
import de.uka.ipd.sdq.stoex.StoexPackage;
import tools.mdsd.library.emfeditutils.itempropertydescriptor.ItemPropertyDescriptorUtils;
import tools.mdsd.library.emfeditutils.itempropertydescriptor.ValueChoiceCalculatorBase;

public class VariableBindingItemProvider extends VariableBindingItemProviderGen {

    private static final Set<EStructuralFeature> LABEL_FEATURES = new HashSet<>(
            Arrays.asList(BehaviourPackage.Literals.VARIABLE_BINDING__BOUND_VALUE,
                    BehaviourPackage.Literals.VARIABLE_BINDING__BOUND_VARIABLE,
                    StoexPackage.Literals.ABSTRACT_NAMED_REFERENCE__REFERENCE_NAME));

    public VariableBindingItemProvider(AdapterFactory adapterFactory) {
        super(adapterFactory);
    }

    @Override
    protected void addBoundVariablePropertyDescriptor(Object object) {
        super.addBoundVariablePropertyDescriptor(object);
        var decorator = ItemPropertyDescriptorUtils.decorateLastDescriptor(itemPropertyDescriptors);
        decorator.setValueChoiceCalculator(
                new ValueChoiceCalculatorBase<>(VariableBinding.class, AbstractNamedReference.class) {
                    @Override
                    protected Collection<?> getValueChoiceTyped(VariableBinding object,
                            List<AbstractNamedReference> typedList) {
                        return Optional.of(object)
                            .map(EObject::eContainer)
                            .filter(BehaviourReuse.class::isInstance)
                            .map(BehaviourReuse.class::cast)
                            .map(BehaviourReuse::getReusedBehaviour)
                            .map(behaviour -> {
                                List<AbstractNamedReference> names = new ArrayList<>();
                                names.addAll(behaviour.getInputVariables());
                                names.addAll(behaviour.getOutputVariables());
                                return names;
                            })
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
        if (notification.getFeature() == BehaviourPackage.Literals.VARIABLE_BINDING__BOUND_VALUE) {
            LabelFeatureMonitoringAdapter.handleFeatureChange(notification, this::notifyChanged);
        }
        super.notifyChanged(notification);
    }

    @Override
    public String getText(Object object) {
        if (!(object instanceof VariableBinding)) {
            return super.getText(object);
        }

        VariableBinding binding = (VariableBinding) object;
        var from = NamedReferenceUtils.toString(binding.getBoundVariable());
        var to = NamedReferenceUtils.toString(binding.getBoundValue());
        return String.format("%s -> %s", from, to);
    }

}
