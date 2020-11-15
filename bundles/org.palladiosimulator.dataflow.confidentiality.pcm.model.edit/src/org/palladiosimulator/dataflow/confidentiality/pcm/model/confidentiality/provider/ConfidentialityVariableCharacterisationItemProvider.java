package org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.provider;

import java.util.Arrays;
import java.util.Collection;
import java.util.List;
import java.util.stream.Collectors;

import org.eclipse.emf.common.notify.AdapterFactory;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.emf.edit.command.CommandParameter;
import org.eclipse.emf.edit.provider.IItemPropertyDescriptor;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.ConfidentialityPackage;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.ConfidentialityVariableCharacterisation;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.expression.VariableCharacterizationLhs;
import org.palladiosimulator.dataflow.dictionary.characterized.DataDictionaryCharacterized.expressions.DataCharacteristicReference;
import org.palladiosimulator.pcm.parameter.ParameterPackage;

public class ConfidentialityVariableCharacterisationItemProvider
        extends ConfidentialityVariableCharacterisationItemProviderGen {

    private static final Collection<EStructuralFeature> IGNORED_PARENT_FEATURES = Arrays.asList(
            ParameterPackage.Literals.VARIABLE_CHARACTERISATION__SPECIFICATION_VARIABLE_CHARACTERISATION,
            ParameterPackage.Literals.VARIABLE_CHARACTERISATION__TYPE);
    
    /**
     * {@inheritDoc}
     */
    public ConfidentialityVariableCharacterisationItemProvider(AdapterFactory adapterFactory) {
        super(adapterFactory);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public List<IItemPropertyDescriptor> getPropertyDescriptors(Object object) {
        var original = super.getPropertyDescriptors(object);       
        original.removeIf(descriptor -> IGNORED_PARENT_FEATURES.contains(descriptor.getFeature(null)));
        return original;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public Collection<? extends EStructuralFeature> getChildrenFeatures(Object object) {
        return super.getChildrenFeatures(object).stream()
            .filter(f -> !IGNORED_PARENT_FEATURES.contains(f))
            .collect(Collectors.toList());
    }

    /**
     * {@inheritDoc}
     */
    @Override
    protected void collectNewChildDescriptors(Collection<Object> newChildDescriptors, Object object) {
        super.collectNewChildDescriptors(newChildDescriptors, object);
        var descriptorsToRemove = newChildDescriptors.stream()
            .filter(CommandParameter.class::isInstance)
            .map(CommandParameter.class::cast)
            .filter(this::isUnapplicableDescriptor)
            .collect(Collectors.toList());
        newChildDescriptors.removeAll(descriptorsToRemove);
    }

    protected boolean isUnapplicableDescriptor(CommandParameter command) {
        if (IGNORED_PARENT_FEATURES.contains(command.getEStructuralFeature())) {
            return true;
        }

        // only usable if pins are available (not the case here)
        if (command.getEValue() instanceof DataCharacteristicReference) {
            return true;
        }

        // remove rhs terms from lhs feature
        if (command
            .getEStructuralFeature() == ConfidentialityPackage.Literals.CONFIDENTIALITY_VARIABLE_CHARACTERISATION__RHS
                && command.getEValue() instanceof VariableCharacterizationLhs) {
            return true;
        }

        return false;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public String getText(Object object) {
        if (object instanceof ConfidentialityVariableCharacterisation) {
            return getString("_UI_ConfidentialityVariableCharacterisation_type");
        }
        return super.getText(object);
    }

}
