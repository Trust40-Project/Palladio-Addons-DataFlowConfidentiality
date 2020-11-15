package org.palladiosimulator.dataflow.confidentiality.pcm.visualizer.io;

import java.util.List;

public class DataFlowNodeElement extends ParentHaving<DataFlowNode> {
	private Entity entity;
	private List<Entity> context;

	public Entity getEntity() {
		return entity;
	}

	public void setEntity(Entity element) {
		this.entity = element;
	}

	public List<Entity> getContext() {
		return context;
	}

	public void setContext(List<Entity> context) {
		this.context = context;
	}

	@Override
	protected void setParentForChildren() {
		// intentionally left blank
	}
}
