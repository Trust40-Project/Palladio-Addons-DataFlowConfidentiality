package org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.repository.provider;

import java.util.Optional;

import org.eclipse.emf.common.notify.AdapterFactory;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.repository.DBOperationInterface;
import org.palladiosimulator.pcm.core.provider.PalladioComponentModelEditPlugin;

public class DBOperationInterfaceItemProvider extends DBOperationInterfaceItemProviderGen {

	public DBOperationInterfaceItemProvider(AdapterFactory adapterFactory) {
		super(adapterFactory);
	}

	@Override
	public Object getImage(Object object) {
		return Optional.ofNullable(PalladioComponentModelEditPlugin.INSTANCE)
				.map(PalladioComponentModelEditPlugin::getPluginResourceLocator)
				.map(l -> l.getImage("full/obj16/OperationInterface"))
				.map(img -> this.overlayImage(object, img))
				.orElseGet(() -> super.getImage(object));
	}

	@Override
	public String getText(Object object) {
		final String label = ((DBOperationInterface) object).getEntityName();
		return label == null || label.length() == 0 ? this.getString("_UI_DBOperationInterface_type")
				: this.getString("_UI_DBOperationInterface_type") + " " + label;
	}

}
