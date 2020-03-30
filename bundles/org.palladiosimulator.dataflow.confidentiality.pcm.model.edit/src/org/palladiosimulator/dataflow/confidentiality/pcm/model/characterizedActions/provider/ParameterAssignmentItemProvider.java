package org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.provider;

import java.util.Collection;

import org.eclipse.emf.common.notify.AdapterFactory;
import org.eclipse.emf.edit.command.CommandParameter;
import org.palladiosimulator.dataflow.dictionary.characterized.DataDictionaryCharacterized.expressions.DataCharacteristicReference;

public class ParameterAssignmentItemProvider extends ParameterAssignmentItemProviderGen {

	public ParameterAssignmentItemProvider(AdapterFactory adapterFactory) {
		super(adapterFactory);
	}

	@Override
	protected void collectNewChildDescriptors(Collection<Object> newChildDescriptors, Object object) {
		super.collectNewChildDescriptors(newChildDescriptors, object);
		newChildDescriptors.removeIf(cd -> {
			if (!(cd instanceof CommandParameter)) {
				return false;
			}
			Object value = ((CommandParameter)cd).getValue();
				if (value instanceof DataCharacteristicReference) {
					return true;
				}
			return false;
		});
	}
	
}
