package org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.behaviour.provider;

import org.eclipse.emf.common.notify.AdapterFactory;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.behaviour.ReusableBehaviour;

public class ReusableBehaviourItemProvider extends ReusableBehaviourItemProviderGen {

    public ReusableBehaviourItemProvider(AdapterFactory adapterFactory) {
        super(adapterFactory);
    }

    @Override
    public String getText(Object object) {
        if (!(object instanceof ReusableBehaviour)) {
            return super.getText(object);
        }
        ReusableBehaviour behaviour = (ReusableBehaviour) object;
        return String.format("%s %s (%s)", getString("_UI_ReusableBehaviour_type"), behaviour.getEntityName(),
                behaviour.getId());
    }

}
