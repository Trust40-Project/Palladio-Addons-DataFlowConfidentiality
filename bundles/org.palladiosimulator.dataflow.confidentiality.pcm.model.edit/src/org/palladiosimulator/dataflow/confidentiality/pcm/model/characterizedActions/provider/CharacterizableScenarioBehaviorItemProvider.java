package org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.provider;

import java.util.Optional;

import org.eclipse.emf.common.notify.AdapterFactory;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.CharacterizableScenarioBehavior;
import org.palladiosimulator.pcm.core.provider.PalladioComponentModelEditPlugin;

public class CharacterizableScenarioBehaviorItemProvider extends CharacterizableScenarioBehaviorItemProviderGen {

	public CharacterizableScenarioBehaviorItemProvider(AdapterFactory adapterFactory) {
		super(adapterFactory);
	}
	
	public String getText(Object object) {
		return Optional.ofNullable(object)
				.filter(CharacterizableScenarioBehavior.class::isInstance)
				.map(CharacterizableScenarioBehavior.class::cast)
				.map(CharacterizableScenarioBehavior::getEntityName)
				.map(name -> getString("_UI_CharacterizableScenarioBehavior_type") + " " + name)
				.orElse(super.getText(object));
	}
	
	@Override
	public Object getImage(Object object) {
		return Optional.ofNullable(PalladioComponentModelEditPlugin.INSTANCE)
				.map(PalladioComponentModelEditPlugin::getPluginResourceLocator)
				.map(l -> l.getImage("full/obj16/ScenarioBehaviour"))
				.map(img -> this.overlayImage(object, img))
				.orElseGet(() -> super.getImage(object));
	}

}
