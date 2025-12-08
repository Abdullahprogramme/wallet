import mongoose, { Document, Schema } from "mongoose";

export interface ITransaction extends Document {
    userId: mongoose.Types.ObjectId;
    categoryId: mongoose.Types.ObjectId;
    amount: number;
    type: "ADD" | "SUBTRACT";
    date: Date;
}

const TransactionSchema = new Schema<ITransaction>({
    userId: { type: Schema.Types.ObjectId, ref: "User", required: true },
    categoryId: { type: Schema.Types.ObjectId, ref: "Category", required: true },
    amount: { type: Number, required: true },
    type: { type: String, enum: ["ADD", "SUBTRACT"], required: true },
    date: { type: Date, default: Date.now }
});

export default mongoose.model<ITransaction>("Transaction", TransactionSchema);
