package org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.provider;

import java.util.Collection;

import org.eclipse.emf.common.notify.AdapterFactory;
import org.eclipse.emf.edit.command.CommandParameter;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.CharacterizedActionsPackage;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.expressions.ParameterCharacteristicReference;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.expressions.SeffReturnCharacteristicReference;
import org.palladiosimulator.dataflow.dictionary.characterized.DataDictionaryCharacterized.expressions.DataCharacteristicReference;

public class SeffReturnAssignmentItemProvider extends SeffReturnAssignmentItemProviderGen {

	public SeffReturnAssignmentItemProvider(AdapterFactory adapterFactory) {
		super(adapterFactory);
	}

	@Override
	protected void collectNewChildDescriptors(Collection<Object> newChildDescriptors, Object object) {
		super.collectNewChildDescriptors(newChildDescriptors, object);
		newChildDescriptors.removeIf(cd -> {
			if (!(cd instanceof CommandParameter)) {
				return false;
			}
			CommandParameter cp = (CommandParameter)cd;
			Object value = cp.getValue();
				if (value instanceof DataCharacteristicReference) {
					return true;
				}
				if (value instanceof ParameterCharacteristicReference) {
					return true;
				}
				if (value instanceof SeffReturnCharacteristicReference) {
					return cp.getEStructuralFeature() == CharacterizedActionsPackage.Literals.ASSIGNMENT__RHS;
				}
			return false;
		});
	}
	
}
