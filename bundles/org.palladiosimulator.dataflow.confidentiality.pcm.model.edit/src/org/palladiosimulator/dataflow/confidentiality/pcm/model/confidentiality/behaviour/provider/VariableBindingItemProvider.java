package org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.behaviour.provider;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Optional;

import org.eclipse.emf.common.notify.AdapterFactory;
import org.eclipse.emf.ecore.EObject;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.behaviour.BehaviourReuse;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.behaviour.VariableBinding;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.impl.NamedReferenceUtils;

import de.uka.ipd.sdq.stoex.AbstractNamedReference;
import tools.mdsd.library.emfeditutils.itempropertydescriptor.ItemPropertyDescriptorUtils;
import tools.mdsd.library.emfeditutils.itempropertydescriptor.ValueChoiceCalculatorBase;

public class VariableBindingItemProvider extends VariableBindingItemProviderGen {

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
