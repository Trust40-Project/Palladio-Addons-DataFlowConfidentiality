package org.palladiosimulator.dataflow.confidentiality.pcm.editor.sirius;

import java.util.Optional;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.edit.provider.ComposedAdapterFactory;
import org.eclipse.emf.edit.ui.provider.AdapterFactoryLabelProvider;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.ConfidentialityVariableCharacterisation;

/**
 * The services class used by VSM.
 */
public class Services {

    public String getConfidentialityVariableCharacterisationLabel(EObject self) {
        if (!(self instanceof ConfidentialityVariableCharacterisation)) {
            return "invalid";
        }
        var characterisation = (ConfidentialityVariableCharacterisation) self;

        ComposedAdapterFactory composedAdapterFactory = new ComposedAdapterFactory(
                ComposedAdapterFactory.Descriptor.Registry.INSTANCE);
        AdapterFactoryLabelProvider labelProvider = new AdapterFactoryLabelProvider(composedAdapterFactory);

        var lhsLabel = Optional.ofNullable(labelProvider.getText(characterisation.getLhs()))
            .orElse("invalid");
        var rhsLabel = Optional.ofNullable(labelProvider.getText(characterisation.getRhs()))
            .orElse("invalid");
        return String.format("%s := %s", lhsLabel, rhsLabel);
    }

}
