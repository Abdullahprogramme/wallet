import mongoose, { Document, Schema } from "mongoose";

export interface ICategory extends Document {
    userId: mongoose.Types.ObjectId;
    name: string;
    balance: number;
}

const CategorySchema = new Schema<ICategory>({
    userId: { type: Schema.Types.ObjectId, ref: "User", required: true },
    name: { type: String, required: true },
    balance: { type: Number, default: 0 }
});

export default mongoose.model<ICategory>("Category", CategorySchema);
